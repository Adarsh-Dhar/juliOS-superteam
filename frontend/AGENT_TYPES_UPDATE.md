# Agent Types Integration Update

## Overview
The system needs to be updated to support the new agent structure with 3 types of agents:
1. **Crawler Agents** - Platform-specific (e.g., twitter.jl, reddit.jl)
2. **Fixed Analyzers** - sentiment_analyzer and trend_analyzer (always 2)
3. **Consensus Agents** - Odd number of agents for content authenticity scoring

## Agent Types Breakdown

### 1. Crawler Agents
- **Generation**: Automatically based on selected platforms
- **Examples**: twitter.jl, reddit.jl, discord.jl, etc.
- **Count**: Same as number of selected platforms

### 2. Fixed Analyzer Agents (Always 2)
- **sentiment_analyzer**: Sentiment analysis
- **trend_analyzer**: Trend analysis
- **Count**: Always 2 (fixed)

### 3. Consensus Agents
- **Count**: Odd number (1, 3, 5, 7, 9)
- **Purpose**: Content authenticity scoring
- **Scoring System**:
  - bot_likelihood (0-1)
  - engagement_manipulation (0-1)
  - content_authenticity (0-1)
  - **Final Score**: Average of 3 metrics (0-1 with decimals like 0.69, 0.42)

## Required Changes

### 1. Frontend Changes (`frontend/app/campaign/page.tsx`)

#### Interface Updates
```typescript
interface CampaignForm {
  // ... existing fields ...
  crawlerAgents: string[]; // Automatically generated based on platforms
  consensusAgentCount: number; // Odd number of consensus agents
  // Remove analyzerCount
}
```

#### Initial State
```typescript
const [formData, setFormData] = useState<CampaignForm>({
  // ... existing fields ...
  crawlerAgents: [],
  consensusAgentCount: 3, // Start with 3 (odd number)
  // Remove analyzerCount: 2
});
```

#### Agent Count Calculations
```typescript
// Total agents = crawlers + consensus + fixed analyzers
const totalAgents = formData.crawlerAgents.length + formData.consensusAgentCount + 2;

// NFT minting
agentCount: formData.crawlerAgents.length + formData.consensusAgentCount + 2
```

#### UI Updates
- Replace analyzer count slider with consensus agent count slider
- Add fixed analyzer display (always 2)
- Update budget calculations
- Add consensus agent scoring explanation

#### Validation Updates
```typescript
case 1: // Resource Allocation
  return formData.crawlerAgents.length > 0 && 
         formData.consensusAgentCount > 0 && 
         formData.budget > 0;
```

### 2. API Changes (`frontend/app/api/campaigns/route.ts`)

#### Request Processing
```typescript
const crawlerAgents = metadata?.crawlerAgents || [];
const consensusAgentCount = metadata?.consensusAgentCount || 0;
const fixedAnalyzers = metadata?.fixedAnalyzers || ['sentiment_analyzer', 'trend_analyzer'];
const totalAgents = crawlerAgents.length + consensusAgentCount + fixedAnalyzers.length;
```

#### Response Structure
```typescript
metadata: {
  ...metadata,
  crawlerAgents,
  consensusAgentCount,
  fixedAnalyzers,
  totalAgents,
  agentDetails: {
    crawlers: crawlerAgents,
    consensus: consensusAgentCount,
    fixedAnalyzers: fixedAnalyzers,
    total: totalAgents
  }
}
```

#### Logging Updates
```typescript
console.log('Generated Crawler Agents:', crawlerAgents);
console.log('Consensus Agent Count:', consensusAgentCount);
console.log('Fixed Analyzers:', fixedAnalyzers);
console.log('Total Agents:', totalAgents);
```

### 3. Database Changes (`frontend/prisma/schema.prisma`)

#### AgentType Enum Update
```prisma
enum AgentType {
  CRAWLER
  SENTIMENT_ANALYZER
  TREND_ANALYZER
  CONSENSUS
  VALIDATOR
  ANALYTICS
  REPORTER
}
```

#### Campaign Model
```prisma
model Campaign {
  // ... existing fields ...
  metadata Json? // Store agent configuration
}
```

## Implementation Steps

### Step 1: Update Database Schema
1. Update AgentType enum
2. Add metadata field to Campaign model
3. Run migration

### Step 2: Update Frontend
1. Update CampaignForm interface
2. Update initial state
3. Update agent count calculations
4. Update UI components
5. Update validation logic
6. Update logging

### Step 3: Update API
1. Update request processing
2. Update response structure
3. Update logging
4. Update metadata handling

### Step 4: Update Documentation
1. Update agent types documentation
2. Update API documentation
3. Update user guides

## Agent Scoring System

### Consensus Agent Scoring
Each consensus agent provides scores for:
1. **bot_likelihood**: 0-1 (1 = human, 0 = bot)
2. **engagement_manipulation**: 0-1 (1 = authentic, 0 = manipulated)
3. **content_authenticity**: 0-1 (1 = authentic, 0 = fake)

**Final Score**: Average of 3 metrics
- Example: (0.8 + 0.6 + 0.9) / 3 = 0.77
- Range: 0-1 with decimal precision
- Interpretation: 1 = authentic, 0 = fake

## Example Scenarios

### Scenario 1: Twitter + Reddit
- **Crawler Agents**: 2 (twitter.jl, reddit.jl)
- **Fixed Analyzers**: 2 (sentiment_analyzer, trend_analyzer)
- **Consensus Agents**: 3 (user-selected odd number)
- **Total Agents**: 7

### Scenario 2: All Platforms
- **Crawler Agents**: 6 (all platform agents)
- **Fixed Analyzers**: 2 (sentiment_analyzer, trend_analyzer)
- **Consensus Agents**: 5 (user-selected odd number)
- **Total Agents**: 13

### Scenario 3: Single Platform
- **Crawler Agents**: 1 (instagram.jl)
- **Fixed Analyzers**: 2 (sentiment_analyzer, trend_analyzer)
- **Consensus Agents**: 1 (minimum odd number)
- **Total Agents**: 4

## Benefits

1. **Structured Agent Types**: Clear separation of agent responsibilities
2. **Consensus Scoring**: Robust content authenticity verification
3. **Fixed Analyzers**: Consistent sentiment and trend analysis
4. **Platform-Specific Crawlers**: Optimized data collection per platform
5. **Odd Number Consensus**: Prevents voting ties in authenticity scoring

## Migration Notes

- Existing campaigns will need metadata migration
- New campaigns will use the updated agent structure
- API maintains backward compatibility where possible
- Database migration required for new agent types 