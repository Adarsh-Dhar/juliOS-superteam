# Crawler Agents Auto-Generation Changes

## Overview
The campaign creation system has been updated to automatically generate crawler agents based on the selected social media platforms, removing the manual crawler count selection.

## Changes Made

### 1. Frontend Changes (`frontend/app/campaign/page.tsx`)

#### Interface Updates
- Changed `crawlerCount: number` to `crawlerAgents: string[]` in the `CampaignForm` interface
- Updated initial state to use empty array for `crawlerAgents`

#### Platform Configuration
- Updated `platforms` array to include agent information:
  ```javascript
  const platforms = [
    { id: 'twitter', name: 'Twitter', icon: '🐦', agent: 'twitter.jl' },
    { id: 'reddit', name: 'Reddit', icon: '🤖', agent: 'reddit.jl' },
    { id: 'discord', name: 'Discord', icon: '💬', agent: 'discord.jl' },
    { id: 'telegram', name: 'Telegram', icon: '📱', agent: 'telegram.jl' },
    { id: 'instagram', name: 'Instagram', icon: '📸', agent: 'instagram.jl' },
    { id: 'youtube', name: 'YouTube', icon: '📺', agent: 'youtube.jl' }
  ];
  ```

#### Agent Generation Logic
- Added `generateCrawlerAgents()` function that maps selected platforms to their corresponding Julia agents
- Added `useEffect` hook to automatically update crawler agents when platforms change
- Updated validation logic to check for `crawlerAgents.length > 0`

#### UI Updates
- Removed crawler count slider from resource allocation step
- Updated display to show generated agent names
- Updated budget calculations to use `crawlerAgents.length`

### 2. API Changes (`frontend/app/api/campaigns/route.ts`)

#### Request Processing
- Updated to handle `crawlerAgents` array instead of `crawlerCount`
- Added logic to calculate total agents: `crawlerAgents.length + analyzerCount`
- Enhanced metadata structure to include agent details

#### Response Structure
- Updated mock response to include detailed agent information
- Added `agentDetails` object with crawlers, analyzers, and total counts

### 3. Database Changes (`frontend/prisma/schema.prisma`)

#### Campaign Model
- Added `metadata Json?` field to store campaign configuration including crawler agents
- This allows storing the full agent configuration and platform details

## How It Works

### Agent Generation
1. User selects social media platforms (e.g., Twitter, Reddit)
2. System automatically generates corresponding Julia agents:
   - Twitter → `twitter.jl`
   - Reddit → `reddit.jl`
   - Discord → `discord.jl`
   - etc.

### Validation
- Campaign configuration step requires at least one platform selected
- Resource allocation step requires at least one crawler agent generated
- Total agent count = number of selected platforms + analyzer count

### Example Scenarios

#### Scenario 1: Twitter + Reddit
- Selected platforms: `['twitter', 'reddit']`
- Generated agents: `['twitter.jl', 'reddit.jl']`
- Total agents: 2 crawlers + analyzer count

#### Scenario 2: All Platforms
- Selected platforms: `['twitter', 'reddit', 'discord', 'telegram', 'instagram', 'youtube']`
- Generated agents: `['twitter.jl', 'reddit.jl', 'discord.jl', 'telegram.jl', 'instagram.jl', 'youtube.jl']`
- Total agents: 6 crawlers + analyzer count

#### Scenario 3: Single Platform
- Selected platforms: `['instagram']`
- Generated agents: `['instagram.jl']`
- Total agents: 1 crawler + analyzer count

## Benefits

1. **Automatic Scaling**: Number of crawlers automatically scales with selected platforms
2. **Platform-Specific Agents**: Each platform gets its dedicated Julia agent
3. **Simplified UI**: Removed manual crawler count selection
4. **Better Resource Management**: More accurate agent count for NFT minting
5. **Extensible**: Easy to add new platforms and their corresponding agents

## Migration Notes

- Existing campaigns will continue to work with the old `crawlerCount` field
- New campaigns will use the `crawlerAgents` array
- Database migration adds `metadata` field for storing agent configuration
- API maintains backward compatibility while supporting new structure

## Testing

The system has been tested with various platform combinations:
- ✅ Single platform selection
- ✅ Multiple platform selection  
- ✅ All platforms selection
- ✅ No platforms selection (validation prevents proceeding)
- ✅ Agent generation accuracy
- ✅ UI updates correctly
- ✅ API handles new structure 