# Results Summary Template for Research Article

## Overview

This document provides templates for integrating classification system results into a research article. It includes LaTeX code snippets, figure captions, table templates, and bibliography entries.

## Table of Contents

1. [Results Section Template](#results-section-template)
2. [Figure Captions](#figure-captions)
3. [Table Templates](#table-templates)
4. [LaTeX Code Snippets](#latex-code-snippets)
5. [Bibliography Entries](#bibliography-entries)
6. [Methodology Description](#methodology-description)

---

## Results Section Template

### Complete Results Section (LaTeX)

```latex
\section{Classification Results}

\subsection{Model Performance Comparison}

Three deep learning architectures were evaluated for corrosion severity classification: ResNet50, EfficientNet-B0, and a custom CNN. Table~\ref{tab:model_comparison} presents the quantitative performance metrics for each model on the test set.

ResNet50 achieved the highest overall accuracy of XX.XX\%, with a macro-averaged F1-score of X.XXXX. EfficientNet-B0 demonstrated competitive performance with XX.XX\% accuracy while requiring fewer parameters. The custom CNN, despite its simpler architecture, achieved XX.XX\% accuracy, demonstrating the feasibility of lightweight models for this task.

\subsection{Per-Class Performance Analysis}

Figure~\ref{fig:confusion_matrix_resnet50} shows the confusion matrix for the best-performing model (ResNet50). The model achieved high precision and recall across all three severity classes. Class 0 (None/Light) showed the highest classification accuracy at XX.XX\%, while Class 2 (Severe) achieved XX.XX\% accuracy. The primary source of misclassification occurred between adjacent severity classes, which is expected given the continuous nature of corrosion progression.

Table~\ref{tab:per_class_metrics} details the per-class precision, recall, and F1-scores for all models. All models demonstrated balanced performance across classes, with F1-scores exceeding 0.XX for each severity level.

\subsection{ROC Analysis}

Receiver Operating Characteristic (ROC) curves for multi-class classification are presented in Figure~\ref{fig:roc_curves_resnet50}. Using a one-vs-rest strategy, ResNet50 achieved Area Under the Curve (AUC) scores of X.XXXX, X.XXXX, and X.XXXX for Classes 0, 1, and 2, respectively. These high AUC values indicate excellent discriminative ability across all severity levels.

\subsection{Training Dynamics}

Figure~\ref{fig:training_curves} illustrates the training and validation curves for all three models. ResNet50 and EfficientNet-B0 converged within XX epochs, while the custom CNN required XX epochs. Early stopping was triggered for ResNet50 at epoch XX, preventing overfitting. The validation accuracy closely tracked training accuracy for all models, indicating good generalization.

\subsection{Inference Speed Analysis}

Table~\ref{tab:inference_time} compares the inference times across architectures. The custom CNN achieved the fastest inference at X.XX ms per image (XXX images/second), making it suitable for real-time applications. ResNet50 processed images at XX.XX ms per image, while EfficientNet-B0 achieved XX.XX ms per image. All models exceeded the 30 fps threshold (33 ms per image) required for real-time video processing.

\subsection{Comparison with Segmentation Approach}

Compared to the pixel-level segmentation approach (U-Net/Attention U-Net), the classification system offers significantly faster inference (XX-XXX ms vs XXX-XXXX ms per image) while providing rapid severity assessment. This speed advantage makes the classification system ideal for initial triage in large-scale inspection workflows, with segmentation reserved for detailed analysis of flagged images.
```

---

## Figure Captions

### Confusion Matrix

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.7\textwidth]{figures/confusion_matrix_ResNet50.pdf}
\caption{Confusion matrix for ResNet50 classification model on the test set. Rows represent true labels and columns represent predicted labels. Values are normalized by row and shown as percentages. The model demonstrates strong performance across all three severity classes with minimal misclassification between non-adjacent classes.}
\label{fig:confusion_matrix_resnet50}
\end{figure}
```

### Training Curves

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.9\textwidth]{figures/training_curves_comparison.pdf}
\caption{Training and validation curves for all three classification models. (a) Loss curves showing convergence behavior. (b) Accuracy curves demonstrating learning progression. Solid lines represent training metrics and dashed lines represent validation metrics. Early stopping was applied when validation loss plateaued for 10 consecutive epochs.}
\label{fig:training_curves}
\end{figure}
```

### ROC Curves

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.8\textwidth]{figures/roc_curves_ResNet50.pdf}
\caption{Receiver Operating Characteristic (ROC) curves for ResNet50 using one-vs-rest multi-class strategy. Each curve represents the classification performance for one severity class against all others. The diagonal dashed line represents random classification. Area Under the Curve (AUC) values are shown in the legend, with all classes achieving AUC > 0.95, indicating excellent discriminative ability.}
\label{fig:roc_curves_resnet50}
\end{figure}
```

### Inference Time Comparison

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.7\textwidth]{figures/inference_time_comparison.pdf}
\caption{Inference time comparison across classification architectures. Bar heights represent mean inference time per image in milliseconds, with error bars showing standard deviation over 100 samples. The horizontal dashed line at 33 ms indicates the real-time threshold for 30 fps video processing. All models achieve real-time performance, with the custom CNN offering the fastest inference.}
\label{fig:roc_curves_resnet50}
\end{figure}
```

### Multi-Figure Layout

```latex
\begin{figure*}[htbp]
\centering
\begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{figures/confusion_matrix_ResNet50.pdf}
    \caption{Confusion matrix}
    \label{fig:results_confusion}
\end{subfigure}
\hfill
\begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{figures/roc_curves_ResNet50.pdf}
    \caption{ROC curves}
    \label{fig:results_roc}
\end{subfigure}
\caption{Classification performance visualization for ResNet50. (a) Confusion matrix showing per-class accuracy. (b) ROC curves with AUC scores for multi-class classification using one-vs-rest strategy.}
\label{fig:classification_results}
\end{figure*}
```

---

## Table Templates

### Model Comparison Table

```latex
\begin{table}[htbp]
\centering
\caption{Performance comparison of classification models on the test set. Metrics include overall accuracy, macro-averaged F1-score, mean AUC across all classes, average inference time per image, and throughput in images per second.}
\label{tab:model_comparison}
\begin{tabular}{lcccccc}
\toprule
\textbf{Model} & \textbf{Accuracy} & \textbf{Macro F1} & \textbf{Mean AUC} & \textbf{Inf. Time} & \textbf{Throughput} & \textbf{Params} \\
 & (\%) & & & (ms) & (img/s) & (M) \\
\midrule
ResNet50 & XX.XX & X.XXXX & X.XXXX & XX.XX & XXX.XX & 25.6 \\
EfficientNet-B0 & XX.XX & X.XXXX & X.XXXX & XX.XX & XXX.XX & 5.3 \\
Custom CNN & XX.XX & X.XXXX & X.XXXX & X.XX & XXX.XX & 2.1 \\
\bottomrule
\end{tabular}
\end{table}
```

### Per-Class Metrics Table

```latex
\begin{table}[htbp]
\centering
\caption{Per-class performance metrics for all classification models. Precision, recall, and F1-score are reported for each severity class: Class 0 (None/Light, <10\% corroded area), Class 1 (Moderate, 10-30\% corroded area), and Class 2 (Severe, >30\% corroded area).}
\label{tab:per_class_metrics}
\begin{tabular}{llccc}
\toprule
\textbf{Model} & \textbf{Class} & \textbf{Precision} & \textbf{Recall} & \textbf{F1-Score} \\
\midrule
\multirow{3}{*}{ResNet50} 
    & Class 0 (None/Light) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 1 (Moderate) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 2 (Severe) & X.XXXX & X.XXXX & X.XXXX \\
\midrule
\multirow{3}{*}{EfficientNet-B0} 
    & Class 0 (None/Light) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 1 (Moderate) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 2 (Severe) & X.XXXX & X.XXXX & X.XXXX \\
\midrule
\multirow{3}{*}{Custom CNN} 
    & Class 0 (None/Light) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 1 (Moderate) & X.XXXX & X.XXXX & X.XXXX \\
    & Class 2 (Severe) & X.XXXX & X.XXXX & X.XXXX \\
\bottomrule
\end{tabular}
\end{table}
```

### Confusion Matrix Table

```latex
\begin{table}[htbp]
\centering
\caption{Confusion matrix for ResNet50 classification model. Values represent the number of test samples. Rows indicate true labels and columns indicate predicted labels.}
\label{tab:confusion_matrix_resnet50}
\begin{tabular}{lccc}
\toprule
\textbf{True / Predicted} & \textbf{Class 0} & \textbf{Class 1} & \textbf{Class 2} \\
\midrule
\textbf{Class 0 (None/Light)} & XX & X & X \\
\textbf{Class 1 (Moderate)} & X & XX & X \\
\textbf{Class 2 (Severe)} & X & X & XX \\
\bottomrule
\end{tabular}
\end{table}
```

### Dataset Statistics Table

```latex
\begin{table}[htbp]
\centering
\caption{Dataset distribution across severity classes and data splits. The dataset was split using stratified sampling to maintain class balance across training, validation, and test sets.}
\label{tab:dataset_statistics}
\begin{tabular}{lcccc}
\toprule
\textbf{Class} & \textbf{Train} & \textbf{Validation} & \textbf{Test} & \textbf{Total} \\
\midrule
Class 0 (None/Light) & XXX & XX & XX & XXX \\
Class 1 (Moderate) & XXX & XX & XX & XXX \\
Class 2 (Severe) & XXX & XX & XX & XXX \\
\midrule
\textbf{Total} & XXX & XX & XX & XXX \\
\textbf{Percentage} & 70\% & 15\% & 15\% & 100\% \\
\bottomrule
\end{tabular}
\end{table}
```

### Training Configuration Table

```latex
\begin{table}[htbp]
\centering
\caption{Training hyperparameters and configuration settings used for all classification models.}
\label{tab:training_config}
\begin{tabular}{ll}
\toprule
\textbf{Parameter} & \textbf{Value} \\
\midrule
Input Image Size & 224 $\times$ 224 pixels \\
Batch Size & 32 \\
Maximum Epochs & 50 \\
Initial Learning Rate & $1 \times 10^{-4}$ \\
Learning Rate Schedule & Piecewise \\
LR Drop Factor & 0.1 \\
LR Drop Period & 10 epochs \\
Validation Patience & 10 epochs \\
Optimizer & Adam \\
Data Augmentation & Enabled \\
Transfer Learning & Pre-trained on ImageNet \\
Execution Environment & NVIDIA GPU (CUDA) \\
\bottomrule
\end{tabular}
\end{table}
```

---

## LaTeX Code Snippets

### Required Packages

```latex
% In preamble
\usepackage{graphicx}      % For figures
\usepackage{booktabs}      % For professional tables
\usepackage{multirow}      % For multi-row cells
\usepackage{subcaption}    % For subfigures
\usepackage{amsmath}       % For math symbols
\usepackage{siunitx}       % For SI units
```

### Figure Inclusion

```latex
% Single figure
\begin{figure}[htbp]
\centering
\includegraphics[width=0.7\textwidth]{figures/confusion_matrix_ResNet50.pdf}
\caption{Your caption here.}
\label{fig:your_label}
\end{figure}

% Reference in text
As shown in Figure~\ref{fig:your_label}, the model achieves...
```

### Table Inclusion

```latex
% Professional table with booktabs
\begin{table}[htbp]
\centering
\caption{Your caption here.}
\label{tab:your_label}
\begin{tabular}{lcc}
\toprule
\textbf{Column 1} & \textbf{Column 2} & \textbf{Column 3} \\
\midrule
Row 1 & Value 1 & Value 2 \\
Row 2 & Value 3 & Value 4 \\
\bottomrule
\end{tabular}
\end{table}

% Reference in text
Table~\ref{tab:your_label} presents the results...
```

### Inline References

```latex
% Accuracy
The ResNet50 model achieved an accuracy of XX.XX\% on the test set.

% F1-score
The macro-averaged F1-score was X.XXXX.

% AUC
Area Under the Curve (AUC) values ranged from X.XXXX to X.XXXX.

% Inference time
Average inference time was XX.XX~ms per image (XXX~images/second).

% Percentage
Approximately XX\% of images were classified as severe corrosion.
```

---

## Bibliography Entries

### BibTeX Entry for Classification System

```bibtex
@misc{corrosion_classification_system,
  title = {Automated Corrosion Severity Classification System for {ASTM} {A572} Grade 50 Steel Structures},
  author = {[Your Name]},
  year = {2024},
  note = {Deep learning-based classification system using ResNet50, EfficientNet-B0, and custom CNN architectures},
  howpublished = {GitHub repository},
  url = {[Your repository URL]}
}
```

### BibTeX Entry for ResNet

```bibtex
@inproceedings{he2016deep,
  title = {Deep Residual Learning for Image Recognition},
  author = {He, Kaiming and Zhang, Xiangyu and Ren, Shaoqing and Sun, Jian},
  booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  pages = {770--778},
  year = {2016}
}
```

### BibTeX Entry for EfficientNet

```bibtex
@inproceedings{tan2019efficientnet,
  title = {{EfficientNet}: Rethinking Model Scaling for Convolutional Neural Networks},
  author = {Tan, Mingxing and Le, Quoc V.},
  booktitle = {Proceedings of the 36th International Conference on Machine Learning (ICML)},
  pages = {6105--6114},
  year = {2019}
}
```

### BibTeX Entry for Transfer Learning

```bibtex
@article{yosinski2014transferable,
  title = {How Transferable are Features in Deep Neural Networks?},
  author = {Yosinski, Jason and Clune, Jeff and Bengio, Yoshua and Lipson, Hod},
  journal = {Advances in Neural Information Processing Systems},
  volume = {27},
  pages = {3320--3328},
  year = {2014}
}
```

### BibTeX Entry for ImageNet

```bibtex
@inproceedings{deng2009imagenet,
  title = {{ImageNet}: A Large-Scale Hierarchical Image Database},
  author = {Deng, Jia and Dong, Wei and Socher, Richard and Li, Li-Jia and Li, Kai and Fei-Fei, Li},
  booktitle = {2009 IEEE Conference on Computer Vision and Pattern Recognition},
  pages = {248--255},
  year = {2009},
  organization = {IEEE}
}
```

### Citation Examples in Text

```latex
% Citing ResNet
We employed the ResNet50 architecture~\cite{he2016deep}, which has demonstrated excellent performance on image classification tasks.

% Citing EfficientNet
EfficientNet-B0~\cite{tan2019efficientnet} was selected for its parameter efficiency and competitive accuracy.

% Citing transfer learning
Transfer learning from ImageNet~\cite{deng2009imagenet} pre-trained weights~\cite{yosinski2014transferable} significantly improved model convergence and final accuracy.

% Citing your system
The classification system~\cite{corrosion_classification_system} provides rapid severity assessment for corrosion inspection workflows.
```

---

## Methodology Description

### Classification System Methodology (LaTeX)

```latex
\subsection{Corrosion Severity Classification}

\subsubsection{Label Generation}

Severity labels were automatically generated from existing segmentation masks by computing the percentage of corroded pixels relative to total image area. Images were classified into three severity levels based on corroded area percentage: Class 0 (None/Light, $<10\%$), Class 1 (Moderate, $10-30\%$), and Class 2 (Severe, $>30\%$). These thresholds were selected based on domain expertise and inspection guidelines for ASTM A572 Grade 50 steel structures.

\subsubsection{Dataset Preparation}

The dataset was split into training (70\%), validation (15\%), and test (15\%) sets using stratified sampling to maintain class balance across splits. Data augmentation was applied to the training set, including random horizontal and vertical flips, rotation ($\pm 15^\circ$), and brightness/contrast adjustments ($\pm 20\%$). All images were resized to $224 \times 224$ pixels to match the input requirements of the pre-trained models.

\subsubsection{Model Architectures}

Three convolutional neural network architectures were evaluated:

\begin{itemize}
\item \textbf{ResNet50}~\cite{he2016deep}: A 50-layer residual network pre-trained on ImageNet~\cite{deng2009imagenet}. The final fully connected layer was replaced with a new layer outputting three classes. Early convolutional layers were frozen, and the last residual blocks were fine-tuned.

\item \textbf{EfficientNet-B0}~\cite{tan2019efficientnet}: A compound-scaled network balancing depth, width, and resolution. The classification head was replaced to output three severity classes. Transfer learning was applied with selective layer freezing.

\item \textbf{Custom CNN}: A lightweight architecture consisting of four convolutional blocks (32, 64, 128, 256 filters) with batch normalization and max pooling, followed by two fully connected layers with dropout (0.5). This model was trained from scratch without pre-trained weights.
\end{itemize}

\subsubsection{Training Procedure}

All models were trained using the Adam optimizer with an initial learning rate of $1 \times 10^{-4}$. A piecewise learning rate schedule was employed, reducing the learning rate by a factor of 0.1 every 10 epochs. Training was performed for a maximum of 50 epochs with early stopping based on validation loss (patience = 10 epochs). Mini-batch size was set to 32, and training was conducted on an NVIDIA GPU with CUDA acceleration.

\subsubsection{Evaluation Metrics}

Model performance was assessed using multiple metrics:
\begin{itemize}
\item \textbf{Accuracy}: Overall classification accuracy on the test set
\item \textbf{Precision, Recall, F1-Score}: Per-class metrics to evaluate performance across severity levels
\item \textbf{Macro F1-Score}: Unweighted average of per-class F1-scores
\item \textbf{ROC-AUC}: Area under the receiver operating characteristic curve using one-vs-rest strategy
\item \textbf{Inference Time}: Average time per image measured over 100 samples
\end{itemize}

Confusion matrices were generated to analyze misclassification patterns, and ROC curves were plotted to assess discriminative ability across severity classes.
```

---

## Results Interpretation Guidelines

### How to Fill in the Templates

1. **Run the classification system**: Execute `executar_classificacao()` to generate all results
2. **Locate output files**: Results are in `output/classification/results/execution_summary_*.txt`
3. **Extract metrics**: Open the summary file and copy the metrics
4. **Replace placeholders**: Replace `XX.XX` and `X.XXXX` with actual values
5. **Copy figures**: Copy PDF figures from `output/classification/figures/` to your article's figure directory
6. **Copy LaTeX tables**: Copy `.tex` files from `output/classification/latex/` to your article directory
7. **Compile and verify**: Compile your LaTeX document and verify all references work

### Example: Filling in Model Comparison Table

From execution summary:
```
Model                Accuracy   Macro F1   Mean AUC  Inf. Time    Throughput
ResNet50              92.34%     0.9156     0.9523      12.45         80.32
EfficientNetB0        91.87%     0.9089     0.9487      10.23         97.75
CustomCNN             89.45%     0.8834     0.9201       8.67        115.34
```

Replace in LaTeX table:
```latex
ResNet50 & 92.34 & 0.9156 & 0.9523 & 12.45 & 80.32 & 25.6 \\
EfficientNet-B0 & 91.87 & 0.9089 & 0.9487 & 10.23 & 97.75 & 5.3 \\
Custom CNN & 89.45 & 0.8834 & 0.9201 & 8.67 & 115.34 & 2.1 \\
```

---

## Complete Example Article Section

### Full Results Section with All Elements

```latex
\section{Classification Results}

\subsection{Overview}

Three deep learning architectures were evaluated for automated corrosion severity classification: ResNet50~\cite{he2016deep}, EfficientNet-B0~\cite{tan2019efficientnet}, and a custom CNN. Table~\ref{tab:model_comparison} summarizes the quantitative performance of each model.

\begin{table}[htbp]
\centering
\caption{Performance comparison of classification models.}
\label{tab:model_comparison}
\begin{tabular}{lcccc}
\toprule
\textbf{Model} & \textbf{Accuracy (\%)} & \textbf{Macro F1} & \textbf{Mean AUC} & \textbf{Inf. Time (ms)} \\
\midrule
ResNet50 & 92.34 & 0.9156 & 0.9523 & 12.45 \\
EfficientNet-B0 & 91.87 & 0.9089 & 0.9487 & 10.23 \\
Custom CNN & 89.45 & 0.8834 & 0.9201 & 8.67 \\
\bottomrule
\end{tabular}
\end{table}

ResNet50 achieved the highest accuracy at 92.34\%, demonstrating the effectiveness of deep residual architectures for this task. EfficientNet-B0 provided competitive performance (91.87\%) with fewer parameters, while the custom CNN achieved 89.45\% accuracy with the fastest inference time.

\subsection{Detailed Performance Analysis}

Figure~\ref{fig:classification_results} presents the confusion matrix and ROC curves for the best-performing model (ResNet50). The confusion matrix (Figure~\ref{fig:classification_results}a) shows strong diagonal values, indicating accurate classification across all severity levels. Misclassifications primarily occurred between adjacent classes (e.g., Class 0 vs. Class 1), which is expected given the continuous nature of corrosion progression.

\begin{figure*}[htbp]
\centering
\begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{figures/confusion_matrix_ResNet50.pdf}
    \caption{Confusion matrix}
    \label{fig:classification_results_a}
\end{subfigure}
\hfill
\begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{figures/roc_curves_ResNet50.pdf}
    \caption{ROC curves}
    \label{fig:classification_results_b}
\end{subfigure}
\caption{Classification performance for ResNet50. (a) Confusion matrix showing per-class accuracy. (b) ROC curves with AUC scores for multi-class classification.}
\label{fig:classification_results}
\end{figure*}

The ROC curves (Figure~\ref{fig:classification_results}b) demonstrate excellent discriminative ability, with AUC scores exceeding 0.95 for all classes. This indicates that the model can reliably distinguish between severity levels across various decision thresholds.

\subsection{Training Dynamics}

Figure~\ref{fig:training_curves} illustrates the training progression for all models. ResNet50 and EfficientNet-B0 converged within 45 epochs, while the custom CNN required additional training time. Early stopping prevented overfitting, with validation accuracy closely tracking training accuracy.

\begin{figure}[htbp]
\centering
\includegraphics[width=0.9\textwidth]{figures/training_curves_comparison.pdf}
\caption{Training and validation curves for all classification models. Solid lines represent training metrics and dashed lines represent validation metrics.}
\label{fig:training_curves}
\end{figure}

\subsection{Inference Speed}

All models achieved real-time performance, with inference times ranging from 8.67 ms (Custom CNN) to 12.45 ms (ResNet50) per image. These speeds exceed the 30 fps threshold (33 ms per image) required for real-time video processing, making the system suitable for deployment in automated inspection workflows.
```

---

## Tips for Article Integration

1. **Use vector graphics**: Always use PDF figures for publication quality
2. **Consistent formatting**: Match table and figure styles to journal requirements
3. **Clear captions**: Provide detailed, self-contained figure captions
4. **Reference properly**: Use `\ref{}` for all figure and table references
5. **Significant figures**: Use appropriate precision (2-4 decimal places for metrics)
6. **Units**: Always include units (ms, %, images/s)
7. **Abbreviations**: Define abbreviations on first use (e.g., AUC, ROC)
8. **Statistical significance**: Consider adding confidence intervals or p-values
9. **Comparative analysis**: Always compare results to baseline or state-of-the-art
10. **Limitations**: Discuss any limitations or failure cases

---

## Checklist for Article Submission

- [ ] All figures copied to article directory
- [ ] All figures referenced in text
- [ ] All tables formatted with booktabs
- [ ] All metrics filled in with actual values
- [ ] Figure captions are detailed and self-contained
- [ ] Table captions explain all columns
- [ ] Bibliography entries added to .bib file
- [ ] All citations properly formatted
- [ ] Methodology section describes the approach
- [ ] Results section interprets the findings
- [ ] Figures are high resolution (300 DPI for raster, vector for PDF)
- [ ] Tables are properly aligned
- [ ] Units are included for all measurements
- [ ] Abbreviations are defined
- [ ] Cross-references work correctly

---

## Additional Resources

### Generated Files to Use

After running `executar_classificacao()`, use these files:

1. **Figures**: `output/classification/figures/*.pdf`
2. **LaTeX Tables**: `output/classification/latex/*.tex`
3. **Metrics**: `output/classification/results/execution_summary_*.txt`
4. **Detailed Results**: `output/classification/results/*_evaluation_report.mat`

### LaTeX Compilation

```bash
# Compile LaTeX document
pdflatex article.tex
bibtex article
pdflatex article.tex
pdflatex article.tex
```

### Viewing Results

```matlab
% Load evaluation results
load('output/classification/results/ResNet50_evaluation_report.mat');

% Display metrics
disp(results.metrics);

% View confusion matrix
disp(results.confusionMatrix);

% View per-class metrics
disp(results.perClassMetrics);
```

---

## Questions?

For more information:
- **Main README**: `src/classification/README.md`
- **Quick Start**: `src/classification/QUICK_START.md`
- **Configuration Examples**: `src/classification/CONFIGURATION_EXAMPLES.md`
- **Requirements**: `.kiro/specs/corrosion-classification-system/requirements.md`
- **Design**: `.kiro/specs/corrosion-classification-system/design.md`

---

**Note**: This template is designed for flexibility. Adapt the content, formatting, and structure to match your specific journal's requirements and style guidelines.
