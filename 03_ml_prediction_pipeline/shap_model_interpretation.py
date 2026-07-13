"""
SHAP-Based Model Interpretation for MASLD-CVD Risk Prediction
==============================================================
Generates global and patient-level explanations for the trained XGBoost
model using SHAP (SHapley Additive exPlanations).

Outputs
-------
- shap_summary_beeswarm.png     : global feature importance (beeswarm)
- shap_bar_global.png           : mean |SHAP| bar chart
- shap_dependence_<feature>.png : dependence plots for top features
- shap_waterfall_patient_*.png  : individual patient explanations
- shap_values_df.csv            : full SHAP matrix (test set)
- shap_feature_importance.csv   : ranked global importance table

Clinical interpretation notes
------------------------------
SHAP values represent the marginal contribution of each feature to the
log-odds of predicted MACE risk for an individual patient.  Positive SHAP
values push the prediction toward MACE; negative values reduce predicted
risk.  Global importance (mean |SHAP|) ranks features by their average
absolute impact across the test population.

IMPORTANT caveat: SHAP values quantify *predictive* contribution, not
causal effect.  Features such as statin use or antiplatelet drug exposure
may show high importance because they are markers of pre-existing CVD risk
management rather than independent protective factors.  Clinical
interpretation must account for confounding by indication.
"""

from __future__ import annotations

from pathlib import Path

import joblib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import shap

# ---------------------------------------------------------------------------
# Paths – mirror the main pipeline
# ---------------------------------------------------------------------------
OUTPUT_DIR = Path("data/secure_ehr/ml_outputs")
SHAP_DIR   = OUTPUT_DIR / "shap"
SHAP_DIR.mkdir(parents=True, exist_ok=True)

# Clinically meaningful feature labels (maps internal name -> display label)
FEATURE_LABELS: dict[str, str] = {
    "age":              "Age (years)",
    "sex_male":         "Sex (male)",
    "bmi":              "BMI (kg/m²)",
    "sbp":              "Systolic BP (mmHg)",
    "dbp":              "Diastolic BP (mmHg)",
    "glu":              "Fasting glucose (mmol/L)",
    "hba1c":            "HbA1c (%)",
    "tcho":             "Total cholesterol (mmol/L)",
    "hdl":              "HDL-C (mmol/L)",
    "ldl":              "LDL-C (mmol/L)",
    "tg":               "Triglycerides (mmol/L)",
    "alt":              "ALT (U/L)",
    "ast":              "AST (U/L)",
    "ast_alt_ratio":    "AST/ALT ratio",
    "ggt":              "GGT (U/L)",
    "alb":              "Albumin (g/L)",
    "alp":              "ALP (U/L)",
    "cr":               "Creatinine (µmol/L)",
    "egfr":             "eGFR (mL/min/1.73m²)",
    "cysc":             "Cystatin C (mg/L)",
    "ua":               "Uric acid (µmol/L)",
    "hb":               "Haemoglobin (g/dL)",
    "wbc":              "WBC count (×10⁹/L)",
    "plt":              "Platelet count (×10⁹/L)",
    "hscrp":            "hs-CRP (mg/L)",
    "hcy":              "Homocysteine (µmol/L)",
    "ntprobnp":         "NT-proBNP (pg/mL)",
    "med_antiplatelet": "Antiplatelet medication",
    "med_statin":       "Statin medication",
    "med_antihtn":      "Antihypertensive medication",
    "med_glucose_lower":"Glucose-lowering medication",
    "flag_t2dm":        "Type 2 diabetes (comorbidity)",
    "flag_hypertension":"Hypertension (comorbidity)",
    "flag_dyslipidaemia":"Dyslipidaemia (comorbidity)",
    "flag_obesity":     "Obesity (comorbidity)",
}


# ---------------------------------------------------------------------------
# 1. Load model and test data
# ---------------------------------------------------------------------------

def load_artifacts() -> tuple:
    """Load trained model and test-set feature matrix."""
    model = joblib.load(OUTPUT_DIR / "xgboost_masld_cvd_model.pkl")
    X_test = pd.read_csv(OUTPUT_DIR / "X_test_selected.csv")
    y_test = pd.read_csv(OUTPUT_DIR / "y_test.csv").squeeze()
    return model, X_test, y_test


# ---------------------------------------------------------------------------
# 2. Compute SHAP values
# ---------------------------------------------------------------------------

def compute_shap(model, X_test: pd.DataFrame) -> tuple:
    """
    Use TreeExplainer for XGBoost/LightGBM (exact, no approximation).
    Falls back to KernelExplainer for other model types.
    """
    base_model = getattr(model, "base_estimator", model)   # unwrap calibrated
    base_model = getattr(model, "estimator", base_model)

    try:
        explainer   = shap.TreeExplainer(base_model)
        shap_values = explainer.shap_values(X_test)
        expected_val = explainer.expected_value
        print(f"TreeExplainer: base value = {expected_val:.4f}")
    except Exception:
        explainer    = shap.KernelExplainer(
            model.predict_proba, shap.sample(X_test, 100)
        )
        shap_values  = explainer.shap_values(X_test)[1]
        expected_val = explainer.expected_value[1]
        print("KernelExplainer used (slower, approximate)")

    return explainer, shap_values, expected_val


# ---------------------------------------------------------------------------
# 3. Global explanations
# ---------------------------------------------------------------------------

def plot_beeswarm(shap_values: np.ndarray, X_test: pd.DataFrame,
                  max_display: int = 20) -> None:
    """Beeswarm (summary) plot: feature value vs SHAP contribution."""
    # Rename columns to display labels for readability
    X_display = X_test.rename(columns=FEATURE_LABELS)
    shap_df   = pd.DataFrame(shap_values, columns=X_test.columns)
    shap_disp = shap_df.rename(columns=FEATURE_LABELS)

    fig, ax = plt.subplots(figsize=(9, 0.4 * min(max_display, X_test.shape[1]) + 2))
    shap.summary_plot(
        shap_disp.values, X_display,
        plot_type="dot",
        max_display=max_display,
        show=False,
        color_bar_label="Feature value"
    )
    plt.tight_layout()
    plt.savefig(SHAP_DIR / "shap_summary_beeswarm.png", dpi=150,
                bbox_inches="tight")
    plt.close()
    print("Saved: shap_summary_beeswarm.png")


def plot_bar_importance(shap_values: np.ndarray,
                        feature_names: list[str],
                        top_n: int = 20) -> pd.DataFrame:
    """Mean |SHAP| bar chart and importance table."""
    mean_abs_shap = np.abs(shap_values).mean(axis=0)
    importance_df = (
        pd.DataFrame({"feature": feature_names, "mean_abs_shap": mean_abs_shap})
        .sort_values("mean_abs_shap", ascending=False)
        .reset_index(drop=True)
    )
    importance_df["display_label"] = importance_df["feature"].map(
        lambda f: FEATURE_LABELS.get(f, f)
    )

    top = importance_df.head(top_n)
    fig, ax = plt.subplots(figsize=(7, 0.4 * top_n + 2))
    ax.barh(top["display_label"][::-1], top["mean_abs_shap"][::-1],
            color="steelblue")
    ax.set_xlabel("Mean |SHAP value|")
    ax.set_title(f"Top {top_n} features by global SHAP importance")
    fig.tight_layout()
    fig.savefig(SHAP_DIR / "shap_bar_global.png", dpi=150, bbox_inches="tight")
    plt.close(fig)

    importance_df.to_csv(SHAP_DIR / "shap_feature_importance.csv", index=False)
    print(f"Saved: shap_bar_global.png, shap_feature_importance.csv")
    print("\nTop 10 features by mean |SHAP|:")
    print(importance_df[["display_label", "mean_abs_shap"]].head(10).to_string(
        index=False, float_format="{:.4f}".format))
    return importance_df


# ---------------------------------------------------------------------------
# 4. Dependence plots for top features
# ---------------------------------------------------------------------------

def plot_dependence(shap_values: np.ndarray, X_test: pd.DataFrame,
                    top_features: list[str], n_plots: int = 6) -> None:
    """
    Dependence plot: SHAP value vs feature value, coloured by interaction
    feature (auto-selected by SHAP).
    Highlights non-linear relationships and effect modification.
    """
    for feat in top_features[:n_plots]:
        if feat not in X_test.columns:
            continue
        feat_idx = list(X_test.columns).index(feat)
        label    = FEATURE_LABELS.get(feat, feat)

        fig, ax = plt.subplots(figsize=(6, 4))
        shap.dependence_plot(
            feat_idx, shap_values, X_test.rename(columns=FEATURE_LABELS),
            show=False, ax=ax,
            xmin="percentile(2)", xmax="percentile(98)"
        )
        ax.set_title(f"SHAP dependence: {label}")
        ax.set_xlabel(label)
        ax.set_ylabel(f"SHAP value for {label}")
        fig.tight_layout()
        fname = f"shap_dependence_{feat}.png"
        fig.savefig(SHAP_DIR / fname, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"Saved: {fname}")


# ---------------------------------------------------------------------------
# 5. Patient-level (waterfall) explanations
# ---------------------------------------------------------------------------

def plot_waterfall_patients(explainer, shap_values: np.ndarray,
                             X_test: pd.DataFrame, y_test: pd.Series,
                             y_prob: np.ndarray,
                             n_per_group: int = 2) -> None:
    """
    Waterfall plots for illustrative patients:
      – high-risk patients correctly identified (TP)
      – low-risk patients correctly identified (TN)
    Demonstrates individual-level interpretability to clinicians.
    """
    y_pred = (y_prob >= 0.5).astype(int)
    groups = {
        "true_positive":  np.where((y_pred == 1) & (y_test.values == 1))[0],
        "true_negative":  np.where((y_pred == 0) & (y_test.values == 0))[0],
    }
    X_display = X_test.rename(columns=FEATURE_LABELS)

    for group_name, indices in groups.items():
        if len(indices) == 0:
            continue
        chosen = indices[:n_per_group]
        for i, idx in enumerate(chosen):
            shap_expl = shap.Explanation(
                values    = shap_values[idx],
                base_values = (explainer.expected_value
                               if not hasattr(explainer.expected_value, "__len__")
                               else explainer.expected_value[0]),
                data      = X_display.iloc[idx].values,
                feature_names = X_display.columns.tolist()
            )
            fig, ax = plt.subplots(figsize=(10, 5))
            shap.waterfall_plot(shap_expl, max_display=15, show=False)
            plt.title(f"{group_name.replace('_', ' ').title()} – "
                      f"patient {idx} | predicted prob: {y_prob[idx]:.3f}",
                      fontsize=10)
            plt.tight_layout()
            fname = f"shap_waterfall_{group_name}_{i}.png"
            plt.savefig(SHAP_DIR / fname, dpi=150, bbox_inches="tight")
            plt.close()
            print(f"Saved: {fname}")


# ---------------------------------------------------------------------------
# 6. Save full SHAP matrix
# ---------------------------------------------------------------------------

def save_shap_matrix(shap_values: np.ndarray, X_test: pd.DataFrame) -> None:
    shap_df = pd.DataFrame(shap_values, columns=X_test.columns)
    shap_df.to_csv(SHAP_DIR / "shap_values_df.csv", index=False)
    print("Saved: shap_values_df.csv")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("Loading model and test data ...")
    model, X_test, y_test = load_artifacts()

    print("Computing SHAP values ...")
    explainer, shap_values, expected_val = compute_shap(model, X_test)

    y_prob = model.predict_proba(X_test)[:, 1]

    # Global explanations
    print("\n[1] Beeswarm summary plot ...")
    plot_beeswarm(shap_values, X_test)

    print("\n[2] Global bar importance ...")
    importance_df = plot_bar_importance(shap_values, X_test.columns.tolist())

    top_features = importance_df["feature"].head(6).tolist()
    print("\n[3] Dependence plots for top features ...")
    plot_dependence(shap_values, X_test, top_features)

    # Individual explanations
    print("\n[4] Waterfall plots for illustrative patients ...")
    plot_waterfall_patients(explainer, shap_values, X_test, y_test, y_prob)

    # Save matrix
    print("\n[5] Saving SHAP value matrix ...")
    save_shap_matrix(shap_values, X_test)

    print(f"\nAll SHAP outputs saved to: {SHAP_DIR}")


if __name__ == "__main__":
    main()
