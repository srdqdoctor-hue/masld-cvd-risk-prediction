"""
MASLD Cardiovascular Risk Prediction – Complete ML Pipeline
============================================================
Predicts major adverse cardiovascular events (MACE: coronary heart disease,
stroke, or heart failure hospitalisation) in patients with metabolic
dysfunction-associated steatotic liver disease (MASLD) using baseline
electronic health record features.

Pipeline steps
--------------
1. Data loading and schema validation
2. Feature engineering (derived features, categorical encoding)
3. Train / validation / test split (stratified)
4. Missing value imputation (median for numeric, mode for categorical)
5. Feature selection via Recursive Feature Elimination with cross-validation
6. Hyperparameter tuning (RandomizedSearchCV on training fold only)
7. Multi-model comparison with 10-fold stratified cross-validation
8. Final XGBoost model evaluation on held-out test set
   – Discrimination:  AUROC, AUPRC, sensitivity, specificity, PPV, NPV, F1
   – Calibration:     calibration curve, Brier score
   – Clinical utility: decision curve analysis (net benefit)
9. Model persistence

Note on data privacy:
    No patient-level data are included in this repository.
    All file paths reference a local secure mount not accessible externally.
    A synthetic/mock dataset for demonstration is generated at the end of
    this file (see ``generate_mock_dataset()``).
"""

from __future__ import annotations

import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.stats import randint, uniform

from sklearn.experimental import enable_iterative_imputer  # noqa: F401
from sklearn.impute import IterativeImputer
from sklearn.feature_selection import RFECV
from sklearn.model_selection import (
    StratifiedKFold,
    RandomizedSearchCV,
    cross_validate,
    train_test_split,
)
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import (
    RandomForestClassifier,
    ExtraTreesClassifier,
    AdaBoostClassifier,
    GradientBoostingClassifier,
)
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import (
    roc_auc_score,
    average_precision_score,
    brier_score_loss,
    classification_report,
    confusion_matrix,
    f1_score,
)
from sklearn.calibration import calibration_curve, CalibratedClassifierCV

import lightgbm as lgb
import xgboost as xgb
import shap
import matplotlib.pyplot as plt
import joblib

warnings.filterwarnings("ignore")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
DATA_DIR   = Path("data/secure_ehr/outputs")
OUTPUT_DIR = Path("data/secure_ehr/ml_outputs")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# Feature groups  (mirrors the R feature engineering script)
# ---------------------------------------------------------------------------
DEMOGRAPHIC_FEATURES = ["age", "sex_male", "bmi"]

GLYCAEMIC_FEATURES   = ["glu", "hba1c", "flag_t2dm"]

LIPID_FEATURES       = ["tcho", "hdl", "ldl", "tg"]

LIVER_FEATURES       = ["alt", "ast", "ast_alt_ratio", "ggt",
                         "tbil", "dbil", "alb", "alp"]

RENAL_FEATURES       = ["cr", "bun", "cysc", "ua", "umalb_ucr", "egfr"]

HAEMATOLOGICAL       = ["hb", "wbc", "plt", "lymph2", "gran2"]

INFLAMMATORY         = ["hscrp", "crp", "hcy"]

CARDIAC_MARKERS      = ["ntprobnp", "ctnt"]

COAGULATION          = ["inr", "fib"]

VITAL_SIGNS          = ["sbp", "dbp", "hr"]

MEDICATION_FLAGS     = ["med_antiplatelet", "med_statin", "med_antihtn",
                         "med_glucose_lower", "med_insulin"]

COMORBIDITY_FLAGS    = ["flag_hypertension", "flag_dyslipidaemia",
                         "flag_obesity", "flag_other_metabolic"]

ALL_FEATURES = (
    DEMOGRAPHIC_FEATURES + GLYCAEMIC_FEATURES + LIPID_FEATURES +
    LIVER_FEATURES + RENAL_FEATURES + HAEMATOLOGICAL + INFLAMMATORY +
    CARDIAC_MARKERS + COAGULATION + VITAL_SIGNS +
    MEDICATION_FLAGS + COMORBIDITY_FLAGS
)

OUTCOME = "mace_occurred"

# Binary features that should NOT be imputed with IterativeImputer
BINARY_FEATURES = MEDICATION_FLAGS + COMORBIDITY_FLAGS + ["sex_male", "flag_t2dm"]

# ---------------------------------------------------------------------------
# 1. Load and validate data
# ---------------------------------------------------------------------------

def load_data(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    df.columns = df.columns.str.lower()
    missing_features = [f for f in ALL_FEATURES + [OUTCOME] if f not in df.columns]
    if missing_features:
        raise ValueError(f"Missing expected columns: {missing_features}")
    print(f"Loaded {len(df):,} patients, {df.shape[1]} columns")
    print(f"MACE events: {df[OUTCOME].sum()} ({df[OUTCOME].mean()*100:.1f}%)")
    return df


# ---------------------------------------------------------------------------
# 2. Preprocessing
# ---------------------------------------------------------------------------

def preprocess(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    """Return feature matrix X and binary outcome y."""
    X = df[ALL_FEATURES].copy()
    y = df[OUTCOME].astype(int)

    # Binary flags: fill NA with 0 (absent if unrecorded in EHR)
    X[BINARY_FEATURES] = X[BINARY_FEATURES].fillna(0).astype(int)

    # Continuous features: IterativeImputer (MICE-style) for better calibration
    numeric_features = [f for f in ALL_FEATURES if f not in BINARY_FEATURES]
    imputer = IterativeImputer(
        max_iter=10, random_state=42, sample_posterior=False
    )
    X[numeric_features] = imputer.fit_transform(X[numeric_features])

    return X, y


# ---------------------------------------------------------------------------
# 3. Recursive Feature Elimination with cross-validation
# ---------------------------------------------------------------------------

def run_rfe(X_train: pd.DataFrame, y_train: pd.Series,
            n_cv: int = 5) -> list[str]:
    """
    Select features using RFECV with XGBoost estimator.
    Returns list of selected feature names.
    """
    estimator = xgb.XGBClassifier(
        n_estimators=100, max_depth=4,
        use_label_encoder=False, eval_metric="logloss",
        random_state=42, n_jobs=-1
    )
    rfecv = RFECV(
        estimator=estimator,
        step=1,
        cv=StratifiedKFold(n_cv, shuffle=True, random_state=42),
        scoring="roc_auc",
        n_jobs=-1,
        min_features_to_select=5,
    )
    rfecv.fit(X_train, y_train)
    selected = X_train.columns[rfecv.support_].tolist()
    print(f"\nRFECV selected {len(selected)} features "
          f"(optimal: {rfecv.n_features_})")
    return selected


# ---------------------------------------------------------------------------
# 4. Multi-model comparison
# ---------------------------------------------------------------------------

MODELS: dict[str, object] = {
    "Logistic Regression": LogisticRegression(
        C=1.0, solver="lbfgs", max_iter=1000, random_state=42
    ),
    "Random Forest": RandomForestClassifier(
        n_estimators=200, max_depth=6, random_state=42, n_jobs=-1
    ),
    "XGBoost": xgb.XGBClassifier(
        n_estimators=200, max_depth=5, learning_rate=0.1,
        subsample=0.8, colsample_bytree=0.8,
        use_label_encoder=False, eval_metric="logloss",
        random_state=42, n_jobs=-1
    ),
    "LightGBM": lgb.LGBMClassifier(
        n_estimators=200, max_depth=5, learning_rate=0.1,
        random_state=42, n_jobs=-1, verbose=-1
    ),
    "Extra Trees": ExtraTreesClassifier(
        n_estimators=200, max_depth=6, random_state=42, n_jobs=-1
    ),
    "AdaBoost": AdaBoostClassifier(
        n_estimators=100, learning_rate=0.5, random_state=42
    ),
    "Decision Tree": DecisionTreeClassifier(
        max_depth=5, random_state=42
    ),
    "Gradient Boosting": GradientBoostingClassifier(
        n_estimators=200, max_depth=4, learning_rate=0.1, random_state=42
    ),
    "SVM": Pipeline([
        ("scaler", StandardScaler()),
        ("svm", SVC(kernel="rbf", probability=True, random_state=42))
    ]),
}


def compare_models(X: pd.DataFrame, y: pd.Series,
                   n_cv: int = 10) -> pd.DataFrame:
    """10-fold stratified CV comparison across all models."""
    cv = StratifiedKFold(n_splits=n_cv, shuffle=True, random_state=42)
    results = []
    for name, model in MODELS.items():
        scores = cross_validate(
            model, X, y, cv=cv,
            scoring={"auroc": "roc_auc", "auprc": "average_precision",
                     "f1": "f1"},
            n_jobs=-1, return_train_score=False
        )
        results.append({
            "model":           name,
            "auroc_mean":      scores["test_auroc"].mean(),
            "auroc_std":       scores["test_auroc"].std(),
            "auprc_mean":      scores["test_auprc"].mean(),
            "auprc_std":       scores["test_auprc"].std(),
            "f1_mean":         scores["test_f1"].mean(),
            "f1_std":          scores["test_f1"].std(),
        })
        print(f"  {name:25s}  AUROC={scores['test_auroc'].mean():.4f} "
              f"(±{scores['test_auroc'].std():.4f})")

    return pd.DataFrame(results).sort_values("auroc_mean", ascending=False)


# ---------------------------------------------------------------------------
# 5. XGBoost hyperparameter tuning
# ---------------------------------------------------------------------------

XGBOOST_PARAM_DIST = {
    "n_estimators":     randint(100, 600),
    "max_depth":        randint(3, 8),
    "learning_rate":    uniform(0.01, 0.3),
    "subsample":        uniform(0.6, 0.4),
    "colsample_bytree": uniform(0.5, 0.5),
    "min_child_weight": randint(1, 10),
    "gamma":            uniform(0, 0.5),
    "reg_alpha":        uniform(0, 1),
    "reg_lambda":       uniform(0.5, 2),
}


def tune_xgboost(X_train: pd.DataFrame, y_train: pd.Series,
                 n_iter: int = 50, n_cv: int = 5) -> xgb.XGBClassifier:
    """RandomizedSearchCV over XGBoost hyperparameter space."""
    base = xgb.XGBClassifier(
        use_label_encoder=False, eval_metric="logloss",
        random_state=42, n_jobs=-1
    )
    scale_pos_weight = (y_train == 0).sum() / (y_train == 1).sum()
    base.set_params(scale_pos_weight=scale_pos_weight)

    search = RandomizedSearchCV(
        base,
        param_distributions=XGBOOST_PARAM_DIST,
        n_iter=n_iter,
        cv=StratifiedKFold(n_cv, shuffle=True, random_state=42),
        scoring="roc_auc",
        n_jobs=-1,
        random_state=42,
        verbose=1,
    )
    search.fit(X_train, y_train)
    print(f"\nBest CV AUROC: {search.best_score_:.4f}")
    print(f"Best params:   {search.best_params_}")
    return search.best_estimator_


# ---------------------------------------------------------------------------
# 6. Evaluation on held-out test set
# ---------------------------------------------------------------------------

def evaluate_model(model, X_test: pd.DataFrame,
                   y_test: pd.Series, label: str = "XGBoost") -> dict:
    """
    Comprehensive evaluation:
      Discrimination, calibration, and decision curve analysis.
    """
    y_prob = model.predict_proba(X_test)[:, 1]
    y_pred = (y_prob >= 0.5).astype(int)

    tn, fp, fn, tp = confusion_matrix(y_test, y_pred).ravel()
    sensitivity = tp / (tp + fn)
    specificity = tn / (tn + fp)
    ppv = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    npv = tn / (tn + fn) if (tn + fn) > 0 else 0.0

    metrics = {
        "label":       label,
        "auroc":       roc_auc_score(y_test, y_prob),
        "auprc":       average_precision_score(y_test, y_prob),
        "brier_score": brier_score_loss(y_test, y_prob),
        "f1":          f1_score(y_test, y_pred),
        "sensitivity": sensitivity,
        "specificity": specificity,
        "ppv":         ppv,
        "npv":         npv,
    }

    print(f"\n{'='*55}")
    print(f"  {label} — Test-set Evaluation")
    print(f"{'='*55}")
    for k, v in metrics.items():
        if k != "label":
            print(f"  {k:20s}: {v:.4f}")
    print(classification_report(y_test, y_pred, target_names=["No MACE", "MACE"]))

    # --- Calibration plot ---
    fig, ax = plt.subplots(figsize=(5, 5))
    prob_true, prob_pred = calibration_curve(y_test, y_prob, n_bins=10)
    ax.plot(prob_pred, prob_true, "s-", label=label)
    ax.plot([0, 1], [0, 1], "k--", label="Perfect calibration")
    ax.set_xlabel("Mean predicted probability")
    ax.set_ylabel("Fraction of positives")
    ax.set_title(f"Calibration curve – {label}")
    ax.legend()
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / f"calibration_curve_{label.lower().replace(' ', '_')}.png",
                dpi=150)
    plt.close(fig)

    # --- Decision curve analysis (net benefit) ---
    thresholds = np.linspace(0.01, 0.99, 200)
    net_benefit, treat_all = [], []
    n = len(y_test)
    prevalence = y_test.mean()
    for t in thresholds:
        tp_t = ((y_prob >= t) & (y_test == 1)).sum()
        fp_t = ((y_prob >= t) & (y_test == 0)).sum()
        nb = tp_t / n - fp_t / n * (t / (1 - t))
        net_benefit.append(nb)
        treat_all.append(prevalence - (1 - prevalence) * (t / (1 - t)))

    fig, ax = plt.subplots(figsize=(7, 4))
    ax.plot(thresholds, net_benefit, label=label)
    ax.plot(thresholds, treat_all,  "--", label="Treat all")
    ax.axhline(0, color="gray", linewidth=0.8, label="Treat none")
    ax.set_xlim(0, 0.6)
    ax.set_ylim(-0.05, max(net_benefit) + 0.05)
    ax.set_xlabel("Threshold probability")
    ax.set_ylabel("Net benefit")
    ax.set_title(f"Decision curve – {label}")
    ax.legend()
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / f"decision_curve_{label.lower().replace(' ', '_')}.png",
                dpi=150)
    plt.close(fig)

    return metrics


# ---------------------------------------------------------------------------
# 7. Main pipeline
# ---------------------------------------------------------------------------

def main():
    # --- Load ---
    df = load_data(DATA_DIR / "masld_baseline_features.csv")
    X, y = preprocess(df)

    # --- Split: 70% train / 15% validation / 15% test ---
    X_trainval, X_test, y_trainval, y_test = train_test_split(
        X, y, test_size=0.15, stratify=y, random_state=42
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_trainval, y_trainval, test_size=0.15 / 0.85,
        stratify=y_trainval, random_state=42
    )
    print(f"\nData split — train: {len(X_train)}, val: {len(X_val)}, "
          f"test: {len(X_test)}")

    # --- Feature selection ---
    print("\n[1] Running RFECV for feature selection ...")
    selected_features = run_rfe(X_train, y_train)
    X_train_sel = X_train[selected_features]
    X_val_sel   = X_val[selected_features]
    X_test_sel  = X_test[selected_features]
    pd.Series(selected_features).to_csv(
        OUTPUT_DIR / "selected_features_rfe.csv", index=False, header=False
    )

    # --- Multi-model comparison ---
    print("\n[2] Multi-model 10-fold CV comparison ...")
    comparison_df = compare_models(X_train_sel, y_train)
    comparison_df.to_csv(OUTPUT_DIR / "model_comparison.csv", index=False)
    print("\nModel comparison saved to model_comparison.csv")

    # --- XGBoost tuning ---
    print("\n[3] Tuning XGBoost (best-performing model) ...")
    best_xgb = tune_xgboost(X_train_sel, y_train)

    # --- Calibrate best model ---
    calibrated_xgb = CalibratedClassifierCV(best_xgb, cv="prefit", method="isotonic")
    calibrated_xgb.fit(X_val_sel, y_val)

    # --- Test-set evaluation ---
    print("\n[4] Evaluating on held-out test set ...")
    metrics = evaluate_model(calibrated_xgb, X_test_sel, y_test, label="XGBoost")
    pd.DataFrame([metrics]).to_csv(OUTPUT_DIR / "test_metrics.csv", index=False)

    # --- Save model ---
    joblib.dump(calibrated_xgb, OUTPUT_DIR / "xgboost_masld_cvd_model.pkl")
    print("\nModel saved to xgboost_masld_cvd_model.pkl")

    # --- SHAP (run separately for full detail – see shap_model_interpretation.py) ---
    print("\n[5] Computing global SHAP values (summary) ...")
    explainer = shap.TreeExplainer(best_xgb)
    shap_values = explainer.shap_values(X_test_sel)
    shap.summary_plot(shap_values, X_test_sel, show=False)
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "shap_summary_plot.png", dpi=150,
                bbox_inches="tight")
    plt.close()
    print("SHAP summary plot saved.")

    print("\nPipeline complete.")


# ---------------------------------------------------------------------------
# Synthetic dataset for demonstration (no patient data required)
# ---------------------------------------------------------------------------

def generate_mock_dataset(n: int = 500, seed: int = 42) -> pd.DataFrame:
    """
    Generates a small synthetic dataset with realistic MASLD feature
    distributions for pipeline demonstration without real patient data.
    """
    rng = np.random.default_rng(seed)
    n_mace = int(n * 0.18)   # ~18% event rate (consistent with literature)
    y = np.zeros(n, dtype=int)
    y[:n_mace] = 1
    rng.shuffle(y)

    data = {
        "age":             rng.normal(55, 12, n).clip(18, 90),
        "sex_male":        rng.integers(0, 2, n),
        "bmi":             rng.normal(27, 5, n).clip(15, 55),
        "sbp":             rng.normal(130, 18, n).clip(80, 220),
        "dbp":             rng.normal(80, 12, n).clip(50, 130),
        "hr":              rng.normal(76, 14, n).clip(40, 130),
        "glu":             rng.normal(6.5, 2.0, n).clip(2, 25),
        "hba1c":           rng.normal(7.2, 1.5, n).clip(4, 14),
        "tcho":            rng.normal(4.8, 1.2, n).clip(1.5, 12),
        "hdl":             rng.normal(1.2, 0.3, n).clip(0.3, 3),
        "ldl":             rng.normal(2.8, 0.9, n).clip(0.5, 8),
        "tg":              rng.normal(2.0, 1.2, n).clip(0.3, 12),
        "alt":             rng.normal(40, 25, n).clip(5, 300),
        "ast":             rng.normal(38, 22, n).clip(5, 300),
        "ast_alt_ratio":   rng.normal(1.0, 0.4, n).clip(0.3, 5),
        "ggt":             rng.normal(55, 40, n).clip(5, 600),
        "tbil":            rng.normal(14, 6, n).clip(3, 80),
        "dbil":            rng.normal(5, 3, n).clip(0.5, 30),
        "alb":             rng.normal(42, 5, n).clip(20, 60),
        "alp":             rng.normal(80, 35, n).clip(20, 500),
        "cr":              rng.normal(78, 25, n).clip(30, 600),
        "bun":             rng.normal(5.5, 2.5, n).clip(1, 30),
        "cysc":            rng.normal(0.9, 0.25, n).clip(0.4, 5),
        "ua":              rng.normal(340, 90, n).clip(100, 900),
        "umalb_ucr":       rng.exponential(30, n).clip(0, 3000),
        "egfr":            rng.normal(85, 22, n).clip(10, 130),
        "hb":              rng.normal(13.5, 2, n).clip(5, 20),
        "wbc":             rng.normal(6.5, 2, n).clip(1, 20),
        "plt":             rng.normal(200, 70, n).clip(30, 700),
        "lymph2":          rng.normal(1.8, 0.6, n).clip(0.2, 6),
        "gran2":           rng.normal(4.2, 1.5, n).clip(0.5, 15),
        "hscrp":           rng.exponential(3, n).clip(0, 100),
        "crp":             rng.exponential(5, n).clip(0, 200),
        "hcy":             rng.normal(12, 5, n).clip(3, 80),
        "ntprobnp":        rng.exponential(200, n).clip(0, 10000),
        "ctnt":            rng.exponential(0.02, n).clip(0, 5),
        "inr":             rng.normal(1.05, 0.15, n).clip(0.7, 5),
        "fib":             rng.normal(3.2, 0.8, n).clip(0.5, 10),
        "med_antiplatelet":  rng.integers(0, 2, n),
        "med_statin":        rng.integers(0, 2, n),
        "med_antihtn":       rng.integers(0, 2, n),
        "med_glucose_lower": rng.integers(0, 2, n),
        "med_insulin":       rng.integers(0, 2, n),
        "flag_t2dm":         rng.integers(0, 2, n),
        "flag_hypertension": rng.integers(0, 2, n),
        "flag_dyslipidaemia":rng.integers(0, 2, n),
        "flag_obesity":      rng.integers(0, 2, n),
        "flag_other_metabolic": rng.integers(0, 2, n),
        "mace_occurred":   y,
    }

    # Introduce realistic missingness
    miss_rates = {"hba1c": 0.25, "cysc": 0.30, "umalb_ucr": 0.40,
                  "ntprobnp": 0.45, "ctnt": 0.50}
    df = pd.DataFrame(data)
    for col, rate in miss_rates.items():
        mask = rng.random(n) < rate
        df.loc[mask, col] = np.nan

    return df


if __name__ == "__main__":
    # Uncomment to run on real data (requires secure data mount):
    # main()

    # Demonstration on synthetic data:
    print("=== Running pipeline demonstration on synthetic dataset ===\n")
    mock_df = generate_mock_dataset(n=800)
    mock_df.to_csv(DATA_DIR / "masld_baseline_features.csv", index=False)
    main()
