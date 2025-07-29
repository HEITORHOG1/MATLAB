# Implementation Plan

- [x] 0. **SETUP: Define single entry point and clean duplicates**





  - Establish `executar_comparacao.m` as the single main entry point
  - Rename or remove duplicate main files (`main_sistema_comparacao.m`, `executar_comparacao_automatico.m`)
  - Update README and documentation to reference only the single entry point
  - Ensure the main file has all necessary functionality
  - _Requirements: 5.1, 5.2_
-

- [x] 1. Create DataTypeConverter utility class




  - Implement static methods for categorical to numeric conversions
  - Add validation methods for data type checking
  - Create safe conversion methods with error handling
  - _Requirements: 1.1, 1.2, 3.1, 3.2_

- [x] 2. Create PreprocessingValidator utility class





  - Implement image data validation methods
  - Add mask data validation methods
  - Create data preparation methods for RGB operations
  - _Requirements: 1.3, 3.1, 3.4_
- [x] 3. Create VisualizationHelper utility class

















































- [ ] 3. Create VisualizationHelper utility class

  - Implement safe image display preparation methods
  - Add mask visualization preparation methods
  - Create safe imshow wrapper with error handling
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 4. Fix preprocessDataCorrigido.m function





  - Add type validation before rgb2gray operations
  - Implement safe categorical to numeric conversions
  - Add error handling with graceful fallbacks
  - _Requirements: 1.1, 1.3, 3.3, 4.1_
-

- [x] 5. Fix preprocessDataMelhorado.m function




  - Add type validation before image processing operations
  - Implement consistent categorical handling
  - Add error recovery mechanisms
  - _Requirements: 1.1, 1.3, 3.3, 4.1_
-
-

- [x] 6. Fix visualization function in comparacao_unet_attention_final.m















  - Replace direct imshow calls with safe visualization methods
  - Add proper categorical to uint8 conversions for display
  - Implement error handling for visualization generation
  - _Requirements: 2.1, 2.2, 2.4, 3.3_
-

- [x] 7. **CRITICAL: Fix categorical to binary conversion logic**




  - Replace `double(categorical) > 1` with `(categorical == "foreground")` in all metric functions
  - Update calcular_iou_simples.m with correct conversion logic
  - Update calcular_dice_simples.m with correct conversion logic
  - Update calcular_accuracy_simples.m with correct conversion logic
  - _Requirements: 4.1, 4.2, 4.3_
-

- [x] 8. Create MetricsValidator utility class




  - Implement validation for artificially perfect metrics
  - Add categorical structure validation methods
  - Create warnings for suspicious metric patterns
  - Add debugging tools for categorical data inspection
  - _Requirements: 4.1, 4.2, 6.1, 6.2_

- [x] 9. Standardize categorical creation across all functions





  - Ensure all functions use consistent `[0,1]` labelIDs with `["background","foreground"]`
  - Update preprocessDataCorrigido.m for consistent categorical creation
  - Update preprocessDataMelhorado.m for consistent categorical creation
  - Update internal functions in comparacao_unet_attention_final.m
  - _Requirements: 5.1, 5.2, 5.3_
-

- [x] 10. Fix visualization conversion logic




  - Replace incorrect categorical to uint8 conversions in visualization functions
  - Implement proper `uint8(categorical == "foreground") * 255` conversion
  - Add validation for visualization data before imshow
  - Test visualization generation with corrected data
  - _Requirements: 2.1, 2.2, 2.4_

- [x] 11. Add comprehensive result validation





  - Implement checks for realistic metric ranges
  - Add warnings when all metrics are perfect (1.0000 ± 0.0000)
  - Create validation for visualization image quality
  - Add debugging output for categorical data inspection
  - _Requirements: 6.1, 6.2, 6.3, 6.4_
-

- [x] 12. Create comprehensive unit tests




  - Write tests for DataTypeConverter methods
  - Add tests for PreprocessingValidator functionality
  - Create tests for VisualizationHelper methods
  - Add tests for MetricsValidator functionality
  - Test categorical conversion logic extensively
  - _Requirements: 3.1, 3.2, 3.3, 4.1_

- [x] 13. Create integration tests for corrected pipeline









  - Test complete preprocessing pipeline with corrected categorical handling
  - Validate that metrics show realistic variation (not perfect scores)
  - Test visualization generation produces correct comparison images
  - Validate model evaluation produces meaningful differences between models
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 14. Update error handling and logging









  - Add detailed logging for categorical conversions
  - Implement warnings for detected data inconsistencies
  - Create fallback mechanisms for critical operations
  - Add debugging output for troubleshooting categorical issues
  - _Requirements: 3.3, 3.4, 6.1_


- [x] 15. **VALIDATION: Test corrected system end-to-end**








  - Run complete comparison with corrected categorical handling
  - Verify that metrics show realistic values (not 1.0000 ± 0.0000)
  - Validate that visualization images show actual differences between models
  - Confirm that U-Net vs Attention U-Net comparison produces meaningful results
  - Generate final report with corrected data and visualizations
  - _Requirements: 4.4, 5.4, 6.3, 6.4_