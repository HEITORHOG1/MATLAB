"""
Train All Three Models with Real Data
Trains ResNet50, EfficientNet-B0, and Custom CNN on the 217-image dataset
"""

import os
import json
import time
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.applications import ResNet50, EfficientNetB0
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
from PIL import Image
import matplotlib.pyplot as plt

# Set random seeds for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
tf.random.set_seed(RANDOM_SEED)

# Configuration
IMG_SIZE = (256, 256)
BATCH_SIZE = 32
NUM_CLASSES = 3
EPOCHS = 50

# Training configuration
TRAINING_CONFIG = {
    'resnet50': {
        'learning_rate': 0.0001,
        'optimizer': 'Adam',
        'early_stopping_patience': 10,
        'reduce_lr_patience': 5,
    },
    'efficientnet': {
        'learning_rate': 0.0001,
        'optimizer': 'Adam',
        'early_stopping_patience': 10,
        'reduce_lr_patience': 5,
    },
    'custom_cnn': {
        'learning_rate': 0.001,
        'optimizer': 'Adam',
        'early_stopping_patience': 10,
        'reduce_lr_patience': 5,
    }
}

# Data augmentation configuration
AUGMENTATION_CONFIG = {
    'rotation_range': 20,
    'width_shift_range': 0.2,
    'height_shift_range': 0.2,
    'horizontal_flip': True,
    'zoom_range': 0.2,
    'brightness_range': [0.8, 1.2],
    'fill_mode': 'nearest',
}

def load_dataset_splits():
    """Load dataset splits from JSON"""
    with open('results/dataset_splits_files.json', 'r') as f:
        splits = json.load(f)
    return splits

def create_data_generators(splits):
    """Create data generators for train/val/test"""
    
    # Training data generator with augmentation
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        **AUGMENTATION_CONFIG
    )
    
    # Validation and test data generators (no augmentation)
    val_test_datagen = ImageDataGenerator(rescale=1./255)
    
    # Prepare data
    def prepare_data(split_data):
        images = []
        labels = []
        for item in split_data:
            img = Image.open(item['original_path']).convert('RGB')
            img = img.resize(IMG_SIZE)
            images.append(np.array(img))
            labels.append(item['class'])
        return np.array(images), np.array(labels)
    
    X_train, y_train = prepare_data(splits['train'])
    X_val, y_val = prepare_data(splits['validation'])
    X_test, y_test = prepare_data(splits['test'])
    
    # Convert labels to categorical
    y_train_cat = keras.utils.to_categorical(y_train, NUM_CLASSES)
    y_val_cat = keras.utils.to_categorical(y_val, NUM_CLASSES)
    y_test_cat = keras.utils.to_categorical(y_test, NUM_CLASSES)
    
    print(f"✓ Data loaded:")
    print(f"  Train: {X_train.shape[0]} images")
    print(f"  Val: {X_val.shape[0]} images")
    print(f"  Test: {X_test.shape[0]} images")
    
    return (X_train, y_train_cat), (X_val, y_val_cat), (X_test, y_test_cat)

def build_resnet50():
    """Build ResNet50 model with transfer learning"""
    base_model = ResNet50(
        weights='imagenet',
        include_top=False,
        input_shape=(*IMG_SIZE, 3)
    )
    
    # Freeze early layers
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
    # Add custom classification head
    model = models.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(NUM_CLASSES, activation='softmax')
    ])
    
    return model

def build_efficientnet():
    """Build EfficientNet-B0 model with transfer learning"""
    base_model = EfficientNetB0(
        weights='imagenet',
        include_top=False,
        input_shape=(*IMG_SIZE, 3)
    )
    
    # Freeze early layers
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
    # Add custom classification head
    model = models.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(NUM_CLASSES, activation='softmax')
    ])
    
    return model

def build_custom_cnn():
    """Build custom CNN architecture"""
    model = models.Sequential([
        # Input layer
        layers.Input(shape=(*IMG_SIZE, 3)),
        
        # Conv Block 1
        layers.Conv2D(32, (3, 3), activation='relu', padding='same'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.25),
        
        # Conv Block 2
        layers.Conv2D(64, (3, 3), activation='relu', padding='same'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.25),
        
        # Conv Block 3
        layers.Conv2D(128, (3, 3), activation='relu', padding='same'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.25),
        
        # Conv Block 4
        layers.Conv2D(256, (3, 3), activation='relu', padding='same'),
        layers.BatchNormalization(),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.25),
        
        # Dense layers
        layers.Flatten(),
        layers.Dense(512, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.5),
        layers.Dense(NUM_CLASSES, activation='softmax')
    ])
    
    return model

def train_model(model, model_name, train_data, val_data, config):
    """Train a model with callbacks"""
    
    X_train, y_train = train_data
    X_val, y_val = val_data
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=config['learning_rate']),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Callbacks
    callbacks = [
        EarlyStopping(
            monitor='val_loss',
            patience=config['early_stopping_patience'],
            restore_best_weights=True,
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=config['reduce_lr_patience'],
            min_lr=1e-7,
            verbose=1
        ),
        ModelCheckpoint(
            f'models/{model_name}_best.keras',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Create data generator for training
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        **AUGMENTATION_CONFIG
    )
    
    # Normalize validation data
    X_val_norm = X_val / 255.0
    
    # Train
    print(f"\n{'='*70}")
    print(f"Training {model_name.upper()}")
    print(f"{'='*70}\n")
    
    start_time = time.time()
    
    history = model.fit(
        train_datagen.flow(X_train, y_train, batch_size=BATCH_SIZE),
        steps_per_epoch=len(X_train) // BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_val_norm, y_val),
        callbacks=callbacks,
        verbose=1
    )
    
    training_time = time.time() - start_time
    
    print(f"\n✓ Training completed in {training_time/60:.1f} minutes")
    
    return history, training_time

def evaluate_model(model, model_name, test_data):
    """Evaluate model on test set"""
    
    X_test, y_test = test_data
    X_test_norm = X_test / 255.0
    
    print(f"\n{'='*70}")
    print(f"Evaluating {model_name.upper()} on Test Set")
    print(f"{'='*70}\n")
    
    # Evaluate
    test_loss, test_accuracy = model.evaluate(X_test_norm, y_test, verbose=0)
    
    # Get predictions
    y_pred_probs = model.predict(X_test_norm, verbose=0)
    y_pred = np.argmax(y_pred_probs, axis=1)
    y_true = np.argmax(y_test, axis=1)
    
    # Calculate metrics
    from sklearn.metrics import precision_recall_fscore_support, confusion_matrix
    
    precision, recall, f1, _ = precision_recall_fscore_support(
        y_true, y_pred, average='weighted', zero_division=0
    )
    
    precision_per_class, recall_per_class, f1_per_class, _ = precision_recall_fscore_support(
        y_true, y_pred, average=None, zero_division=0
    )
    
    cm = confusion_matrix(y_true, y_pred)
    
    # Measure inference time
    print("Measuring inference time...")
    inference_times = []
    for _ in range(100):
        start = time.time()
        _ = model.predict(X_test_norm[:1], verbose=0)
        inference_times.append((time.time() - start) * 1000)  # Convert to ms
    
    mean_inference_time = np.mean(inference_times)
    std_inference_time = np.std(inference_times)
    
    results = {
        'model_name': model_name,
        'test_loss': float(test_loss),
        'test_accuracy': float(test_accuracy),
        'precision_weighted': float(precision),
        'recall_weighted': float(recall),
        'f1_weighted': float(f1),
        'precision_per_class': [float(p) for p in precision_per_class],
        'recall_per_class': [float(r) for r in recall_per_class],
        'f1_per_class': [float(f) for f in f1_per_class],
        'confusion_matrix': cm.tolist(),
        'inference_time_mean_ms': float(mean_inference_time),
        'inference_time_std_ms': float(std_inference_time),
    }
    
    print(f"\n📊 Results:")
    print(f"  Accuracy: {test_accuracy:.4f}")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall: {recall:.4f}")
    print(f"  F1-Score: {f1:.4f}")
    print(f"  Inference Time: {mean_inference_time:.2f} ± {std_inference_time:.2f} ms")
    
    return results

def save_training_history(history, model_name, training_time):
    """Save training history to JSON"""
    history_dict = {
        'model_name': model_name,
        'training_time_seconds': float(training_time),
        'epochs': len(history.history['loss']),
        'history': {
            'loss': [float(x) for x in history.history['loss']],
            'accuracy': [float(x) for x in history.history['accuracy']],
            'val_loss': [float(x) for x in history.history['val_loss']],
            'val_accuracy': [float(x) for x in history.history['val_accuracy']],
        }
    }
    
    with open(f'results/{model_name}_training_history.json', 'w') as f:
        json.dump(history_dict, f, indent=2)
    
    print(f"✓ Training history saved to: results/{model_name}_training_history.json")

def save_evaluation_results(results, model_name):
    """Save evaluation results to JSON"""
    with open(f'results/{model_name}_evaluation_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"✓ Evaluation results saved to: results/{model_name}_evaluation_results.json")

def main():
    print("="*70)
    print("TRAINING ALL MODELS WITH REAL DATA")
    print("="*70)
    print()
    
    # Create directories
    os.makedirs('models', exist_ok=True)
    os.makedirs('results', exist_ok=True)
    
    # Load dataset splits
    print("Loading dataset splits...")
    splits = load_dataset_splits()
    print("✓ Splits loaded")
    print()
    
    # Create data generators
    print("Preparing data...")
    train_data, val_data, test_data = create_data_generators(splits)
    print()
    
    # Models to train
    models_to_train = [
        ('resnet50', build_resnet50, TRAINING_CONFIG['resnet50']),
        ('efficientnet', build_efficientnet, TRAINING_CONFIG['efficientnet']),
        ('custom_cnn', build_custom_cnn, TRAINING_CONFIG['custom_cnn']),
    ]
    
    all_results = {}
    
    for model_name, build_fn, config in models_to_train:
        print(f"\n{'#'*70}")
        print(f"# MODEL: {model_name.upper()}")
        print(f"{'#'*70}\n")
        
        # Build model
        print(f"Building {model_name}...")
        model = build_fn()
        print(f"✓ Model built")
        print(f"  Total parameters: {model.count_params():,}")
        print()
        
        # Train model
        history, training_time = train_model(model, model_name, train_data, val_data, config)
        
        # Save training history
        save_training_history(history, model_name, training_time)
        print()
        
        # Evaluate model
        results = evaluate_model(model, model_name, test_data)
        results['training_time_seconds'] = float(training_time)
        
        # Save evaluation results
        save_evaluation_results(results, model_name)
        print()
        
        all_results[model_name] = results
    
    # Save combined results
    with open('results/all_models_results.json', 'w') as f:
        json.dump(all_results, f, indent=2)
    
    print("\n" + "="*70)
    print("✅ ALL MODELS TRAINED AND EVALUATED SUCCESSFULLY!")
    print("="*70)
    print()
    print("Results saved to:")
    print("  - models/ (trained model weights)")
    print("  - results/ (training histories and evaluation results)")
    print()
    print("Next step: Generate figures with real data")

if __name__ == '__main__':
    main()
