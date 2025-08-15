# Organization Module

This module provides automatic organization and management of segmentation results.

## Components

- **ResultsOrganizer.m**: Main class for organizing segmentation results into structured directories
- **FileManager.m**: Utilities for file management, compression, and cleanup
- **HTMLGenerator.m**: Generates navigable HTML indexes for result exploration
- **MetadataExporter.m**: Exports summaries and metadata in standard formats

## Features

- Hierarchical directory structure with sessions, models, and comparisons
- Consistent naming conventions with timestamps and metrics
- Automatic compression of old results
- HTML gallery generation for visual exploration
- Export to JSON, CSV, and other standard formats

## Usage

```matlab
% Create organizer
organizer = ResultsOrganizer();

% Organize results from a comparison session
sessionId = organizer.organizeResults(unetResults, attentionResults, config);

% Generate HTML index
organizer.generateHTMLIndex(sessionId);

% Export metadata
organizer.exportMetadata(sessionId, 'json');
```