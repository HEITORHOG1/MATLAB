"""
Generate Figure 8: Grad-CAM Explainability Analysis
Shows what regions of images influence model predictions
"""

import os
import json
import numpy as np
import tensorflow as tf
from tensorflow import keras
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.cm as cm

# Configuration
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif']
plt.rcParams['font.size'] = 9
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300

IMG_SIZE = (256, 256)

def load_model_and_data():
    """Load trained models and test data"""
    # Load models
    resnet50 = keras.models.load_model('models/resnet50_best.keras')
    efficientnet = keras.models.load_model('models/efficientnet_best.keras')
    
    # Load test data
    with open('results/dataset_splits_files.json', 'r') as f:
        splits = json.load(f)
    
    return resnet50, efficientnet, splits['test']

def make_gradcam_heatmap(img_array, model, last_conv_layer_name, pred_index=None):
    """Generate Grad-CAM heatmap"""
    
    # Create a model that maps the input image to the activations
    # of the last conv layer as well as the output predictions
    grad_model = keras.models.Model(
        inputs=[model.inputs],
        outputs=[model.get_layer(last_conv_layer_name).output, model.output]
    )
    
    # Compute the gradient of the top predicted class for our input image
    # with respect to the activations of the last conv layer
    with tf.GradientTape() as tape:
        last_conv_layer_output, preds = grad_model(img_array)
        if pred_index is None:
            pred_index = tf.argmax(preds[0])
        class_channel = preds[:, pred_index]
    
    # This is the gradient of the output neuron (top predicted or chosen)
    # with regard to the output feature map of the last conv layer
    grads = tape.gradient(class_channel, last_conv_layer_output)
    
    # This is a vector where each entry is the mean intensity of the gradient
    # over a specific feature map channel
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))
    
    # We multiply each channel in the feature map array
    # by "how important this channel is" with regard to the top predicted class
    # then sum all the channels to obtain the heatmap class activation
    last_conv_layer_output = last_conv_layer_output[0]
    heatmap = last_conv_layer_output @ pooled_grads[..., tf.newaxis]
    heatmap = tf.squeeze(heatmap)
    
    # For visualization purpose, we will also normalize the heatmap between 0 & 1
    heatmap = tf.maximum(heatmap, 0) / tf.math.reduce_max(heatmap)
    return heatmap.numpy()

def get_last_conv_layer_name(model, model_name):
    """Get the name of the last convolutional layer"""
    if model_name == 'resnet50':
        # For ResNet50, the last conv layer is in the base model
        for layer in reversed(model.layers[0].layers):
            if 'conv' in layer.name.lower():
                return layer.name
    elif model_name == 'efficientnet':
        # For EfficientNet, the last conv layer is in the base model
        for layer in reversed(model.layers[0].layers):
            if 'conv' in layer.name.lower() or 'block' in layer.name.lower():
                return layer.name
    
    # Fallback: find last Conv2D layer
    for layer in reversed(model.layers):
        if isinstance(layer, keras.layers.Conv2D):
            return layer.name
    
    return None

def create_overlay(img, heatmap, alpha=0.4):
    """Create overlay of heatmap on original image"""
    # Resize heatmap to match image size
    heatmap = np.uint8(255 * heatmap)
    heatmap = Image.fromarray(heatmap).resize(IMG_SIZE)
    heatmap = np.array(heatmap)
    
    # Apply colormap
    jet = cm.get_cmap("jet")
    jet_colors = jet(np.arange(256))[:, :3]
    jet_heatmap = jet_colors[heatmap]
    
    # Create an image with RGB colorized heatmap
    jet_heatmap = keras.preprocessing.image.array_to_img(jet_heatmap)
    jet_heatmap = jet_heatmap.resize(IMG_SIZE)
    jet_heatmap = keras.preprocessing.image.img_to_array(jet_heatmap)
    
    # Superimpose the heatmap on original image
    if len(img.shape) == 2:  # Grayscale
        img = np.stack([img] * 3, axis=-1)
    
    superimposed_img = jet_heatmap * alpha + img
    superimposed_img = keras.preprocessing.image.array_to_img(superimposed_img)
    
    return superimposed_img

def select_representative_examples(test_data, model, n_per_class=2):
    """Select representative examples for Grad-CAM visualization"""
    
    # Group by class
    class_examples = {0: [], 1: [], 2: []}
    
    for item in test_data:
        # Load and preprocess image
        img = Image.open(item['original_path']).convert('RGB')
        img = img.resize(IMG_SIZE)
        img_array = np.array(img)
        img_array_norm = np.expand_dims(img_array / 255.0, axis=0)
        
        # Get prediction
        pred_probs = model.predict(img_array_norm, verbose=0)[0]
        pred_class = np.argmax(pred_probs)
        confidence = pred_probs[pred_class]
        
        # Only select if prediction is correct and confident
        if pred_class == item['class'] and confidence > 0.7:
            class_examples[item['class']].append({
                'path': item['original_path'],
                'true_class': item['class'],
                'pred_class': pred_class,
                'confidence': confidence,
                'percentage': item['percentage']
            })
    
    # Select best examples from each class
    selected = []
    for class_id in [0, 1, 2]:
        examples = class_examples[class_id]
        if len(examples) == 0:
            print(f"Warning: No confident correct predictions for Class {class_id}")
            continue
        
        # Sort by confidence and select top n
        examples.sort(key=lambda x: x['confidence'], reverse=True)
        selected.extend(examples[:min(n_per_class, len(examples))])
    
    return selected

def generate_figure8(model, model_name, examples, output_path):
    """Generate Figure 8 with Grad-CAM visualizations"""
    
    # Get last conv layer name
    last_conv_layer_name = get_last_conv_layer_name(model, model_name)
    if last_conv_layer_name is None:
        print(f"ERROR: Could not find last conv layer for {model_name}")
        return
    
    print(f"Using layer: {last_conv_layer_name}")
    
    # Create figure
    n_examples = len(examples)
    fig, axes = plt.subplots(n_examples, 3, figsize=(9, n_examples * 2.5))
    
    if n_examples == 1:
        axes = axes.reshape(1, -1)
    
    class_names = ['Light (<8%)', 'Moderate (8-11%)', 'Severe (≥11%)']
    
    for row, example in enumerate(examples):
        # Load image
        img = Image.open(example['path']).convert('RGB')
        img = img.resize(IMG_SIZE)
        img_array = np.array(img)
        img_array_norm = np.expand_dims(img_array / 255.0, axis=0)
        
        # Generate Grad-CAM heatmap
        heatmap = make_gradcam_heatmap(
            img_array_norm, 
            model, 
            last_conv_layer_name,
            pred_index=example['pred_class']
        )
        
        # Create overlay
        overlay = create_overlay(img_array, heatmap)
        
        # Plot original image
        axes[row, 0].imshow(img_array)
        axes[row, 0].axis('off')
        if row == 0:
            axes[row, 0].set_title('Original Image', fontsize=10, weight='bold')
        
        # Add class label
        class_label = class_names[example['true_class']]
        axes[row, 0].text(0.5, -0.1, f'{class_label}\n{example["percentage"]:.1f}% corrosion',
                         transform=axes[row, 0].transAxes,
                         ha='center', va='top', fontsize=8)
        
        # Plot heatmap
        axes[row, 1].imshow(heatmap, cmap='jet')
        axes[row, 1].axis('off')
        if row == 0:
            axes[row, 1].set_title('Grad-CAM Heatmap', fontsize=10, weight='bold')
        
        # Plot overlay
        axes[row, 2].imshow(overlay)
        axes[row, 2].axis('off')
        if row == 0:
            axes[row, 2].set_title('Overlay', fontsize=10, weight='bold')
        
        # Add confidence
        axes[row, 2].text(0.5, -0.1, f'Confidence: {example["confidence"]:.1%}',
                         transform=axes[row, 2].transAxes,
                         ha='center', va='top', fontsize=8, weight='bold')
    
    plt.suptitle(f'Grad-CAM Explainability Analysis - {model_name}', 
                fontsize=12, weight='bold', y=0.995)
    plt.tight_layout()
    plt.savefig(output_path, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Figure saved: {output_path}")

def main():
    print("="*70)
    print("GENERATING GRAD-CAM EXPLAINABILITY FIGURE")
    print("="*70)
    print()
    
    # Check if models exist
    if not os.path.exists('models/resnet50_best.keras'):
        print("ERROR: Models not found. Please train models first.")
        return
    
    # Load models and data
    print("Loading models and test data...")
    resnet50, efficientnet, test_data = load_model_and_data()
    print("✓ Models and data loaded")
    print()
    
    # Create output directory
    output_dir = 'figuras_pure_classification'
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate Grad-CAM for ResNet50
    print("Generating Grad-CAM for ResNet50...")
    print("Selecting representative examples...")
    examples_resnet = select_representative_examples(test_data, resnet50, n_per_class=2)
    print(f"✓ Selected {len(examples_resnet)} examples")
    
    generate_figure8(
        resnet50,
        'ResNet50',
        examples_resnet,
        os.path.join(output_dir, 'figura_gradcam_resnet50.pdf')
    )
    print()
    
    # Generate Grad-CAM for EfficientNet
    print("Generating Grad-CAM for EfficientNet-B0...")
    print("Selecting representative examples...")
    examples_efficientnet = select_representative_examples(test_data, efficientnet, n_per_class=2)
    print(f"✓ Selected {len(examples_efficientnet)} examples")
    
    generate_figure8(
        efficientnet,
        'EfficientNet-B0',
        examples_efficientnet,
        os.path.join(output_dir, 'figura_gradcam_efficientnet.pdf')
    )
    print()
    
    print("="*70)
    print("✅ GRAD-CAM FIGURES GENERATED SUCCESSFULLY!")
    print("="*70)
    print()
    print(f"Output files saved to: {output_dir}/")
    print("  - figura_gradcam_resnet50.pdf")
    print("  - figura_gradcam_efficientnet.pdf")
    print()
    print("Next step: Update article with explainability analysis")

if __name__ == '__main__':
    main()
