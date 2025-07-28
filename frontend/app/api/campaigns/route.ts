import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// Julia backend API base URL
const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8053/api/v1';

// Agent type mapping for Julia backend
const AGENT_TYPE_MAP = {
  'CRAWLER': 'CRAWLER',
  'SENTIMENT_ANALYZER': 'SENTIMENTANALYZER',
  'TREND_ANALYZER': 'TRENDANALYZER',
  'CONSENSUS': 'CONSENSUSCOORDINATOR'
};

// Platform to agent mapping
const PLATFORM_AGENT_MAP = {
  'twitter': 'TWITTERCRAWLER',
  'reddit': 'REDDITCRAWLER',
};

/**
 * Create agents for a campaign using the Julia backend
 */
async function createCampaignAgents(campaignId: string, metadata: any) {
  const createdAgents = [];
  const errors = [];

  try {
    // Step 1: Create crawler agents
    console.log('=== CREATING CRAWLER AGENTS ===');
    for (const agentName of metadata.crawlerAgents || []) {
      try {
        const platform = agentName.replace('.jl', '') as keyof typeof PLATFORM_AGENT_MAP;
        const agentType = PLATFORM_AGENT_MAP[platform] || 'CRAWLER';
        
        const agentConfig = {
          campaignId,
          platform,
          keywords: metadata.keywords || [],
          hashtags: metadata.hashtags || [],
          spamThreshold: metadata.spamThreshold || 15,
          sentimentThreshold: metadata.sentimentThreshold || 30,
          scrapeInterval: 300, // 5 minutes
          maxPosts: 500,
          region: metadata.region || 'global'
        };

        const agentResponse = await fetch(`${JULIA_API_BASE}/agents`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            name: `${campaignId}_${agentName}`,
            type: agentType,
            parameters: agentConfig
          }),
        });

        if (agentResponse.ok) {
          const agent = await agentResponse.json();
          createdAgents.push(agent);
          console.log(`Created crawler agent: ${agent.name} (${agent.id})`);
        } else {
          const errorText = await agentResponse.text();
          errors.push(`Failed to create crawler agent ${agentName}: ${errorText}`);
          console.error(`Failed to create crawler agent ${agentName}:`, errorText);
        }
      } catch (error) {
        errors.push(`Error creating crawler agent ${agentName}: ${error}`);
        console.error(`Error creating crawler agent ${agentName}:`, error);
      }
    }

    // Step 2: Create fixed analyzer agents
    console.log('=== CREATING FIXED ANALYZER AGENTS ===');
    const fixedAnalyzers = ['sentiment_analyzer', 'trend_analyzer'];
    
    for (const analyzerName of fixedAnalyzers) {
      try {
        const agentType = analyzerName === 'sentiment_analyzer' ? 'SENTIMENTANALYZER' : 'TRENDANALYZER';
        
        const agentConfig = analyzerName === 'sentiment_analyzer' ? {
          min_confidence: 0.6,
          batch_size: 32
        } : {
          languages: ["english"],
          min_trend_growth: 2.0,
          topic_threshold: 0.15
        };

        const agentResponse = await fetch(`${JULIA_API_BASE}/agents`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            name: `${campaignId}_${analyzerName}`,
            type: agentType,
            parameters: agentConfig
          }),
        });

        if (agentResponse.ok) {
          const agent = await agentResponse.json();
          createdAgents.push(agent);
          console.log(`Created ${analyzerName} agent: ${agent.name} (${agent.id})`);
        } else {
          const errorText = await agentResponse.text();
          errors.push(`Failed to create ${analyzerName} agent: ${errorText}`);
          console.error(`Failed to create ${analyzerName} agent:`, errorText);
        }
      } catch (error) {
        errors.push(`Error creating ${analyzerName} agent: ${error}`);
        console.error(`Error creating ${analyzerName} agent:`, error);
      }
    }

    // Step 3: Create consensus agents
    console.log('=== CREATING CONSENSUS AGENTS ===');
    const consensusAgentCount = metadata.consensusAgentCount || 3;
    
    for (let i = 1; i <= consensusAgentCount; i++) {
      try {
        const agentConfig = {
          agentIndex: i,
          totalConsensusAgents: consensusAgentCount,
          scoringMetrics: ['bot_likelihood', 'engagement_manipulation', 'content_authenticity'],
          votingWeight: 1.0,
          consensusThreshold: 0.6,
          personality: {
            bot_skepticism: 0.8 + (Math.random() * 0.4), // 0.8-1.2
            manipulation_sensitivity: 0.5 + (Math.random() * 1.0), // 0.5-1.5
            authenticity_optimism: 0.6 + (Math.random() * 0.8), // 0.6-1.4
            novelty_preference: 0.8 + (Math.random() * 0.4), // 0.8-1.2
            conformity_bias: 0.3 + (Math.random() * 0.4), // 0.3-0.7
            risk_aversion: 0.4 + (Math.random() * 0.7) // 0.4-1.1
          }
        };

        const agentResponse = await fetch(`${JULIA_API_BASE}/agents`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            name: `${campaignId}_consensus_agent_${i}`,
            type: 'CONSENSUSCOORDINATOR',
            parameters: agentConfig
          }),
        });

        if (agentResponse.ok) {
          const agent = await agentResponse.json();
          createdAgents.push(agent);
          console.log(`Created consensus agent ${i}: ${agent.name} (${agent.id})`);
        } else {
          const errorText = await agentResponse.text();
          errors.push(`Failed to create consensus agent ${i}: ${errorText}`);
          console.error(`Failed to create consensus agent ${i}:`, errorText);
        }
      } catch (error) {
        errors.push(`Error creating consensus agent ${i}: ${error}`);
        console.error(`Error creating consensus agent ${i}:`, error);
      }
    }

    console.log('=== AGENT CREATION SUMMARY ===');
    console.log('Total agents created:', createdAgents.length);
    console.log('Crawler agents:', createdAgents.filter(a => a.type?.includes('CRAWLER')).length);
    console.log('Fixed analyzers:', createdAgents.filter(a => a.type?.includes('ANALYZER')).length);
    console.log('Consensus agents:', createdAgents.filter(a => a.type?.includes('CONSENSUS')).length);
    console.log('Errors:', errors.length);
    console.log('=== END AGENT CREATION ===');

    return { createdAgents, errors };
  } catch (error) {
    console.error('Error in createCampaignAgents:', error);
    return { createdAgents: [], errors: [`Failed to create agents: ${error}`] };
  }
}

function getStatusFilter(status?: string) {
  if (!status) return {};
  const now = new Date();
  if (status === 'active') {
    return {
      startDate: { lte: now },
      OR: [
        { endDate: null },
        { endDate: { gte: now } },
      ],
    };
  } else if (status === 'completed') {
    return {
      endDate: { lt: now },
    };
  }
  return {};
}

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const status = searchParams.get('status') || undefined;
  const limit = parseInt(searchParams.get('limit') || '10', 10);
  const offset = parseInt(searchParams.get('offset') || '0', 10);

  const where = getStatusFilter(status);

  const [campaigns, total] = await Promise.all([
    prisma.campaign.findMany({
      where,
      skip: offset,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.campaign.count({ where }),
  ]);

  return NextResponse.json({ campaigns, total });
}

export async function POST(req: NextRequest) {
  try {
    const data = await req.json();
    const { name, hashtag, description, startDate, metadata } = data;
    
    console.log('Received campaign data:', { name, hashtag, description, startDate, metadata });
    
    if (!name || !hashtag) {
      return NextResponse.json({ error: 'Missing name or hashtag' }, { status: 400 });
    }

    // Extract agent configuration from metadata
    const crawlerAgents = metadata?.crawlerAgents || [];
    const consensusAgentCount = metadata?.consensusAgentCount || 0;
    const fixedAnalyzers = metadata?.fixedAnalyzers || ['sentiment_analyzer', 'trend_analyzer'];
    const totalAgents = crawlerAgents.length + consensusAgentCount + fixedAnalyzers.length;

    console.log('Processing campaign creation with:', {
      name,
      hashtag,
      crawlerAgents,
      consensusAgentCount,
      fixedAnalyzers,
      totalAgents
    });

    // Check if campaign with this hashtag already exists
    console.log('Checking for existing campaign with hashtag:', hashtag);
    const existingCampaign = await prisma.campaign.findUnique({
      where: { hashtag },
    });

    if (existingCampaign) {
      console.log('Campaign with hashtag already exists:', existingCampaign.id);
      return NextResponse.json({ error: 'Campaign with this hashtag already exists' }, { status: 409 });
    }

    // Prepare campaign data
    const campaignData = {
      name,
      hashtag,
      description: description || `Campaign monitoring ${metadata?.platforms?.join(', ') || 'various platforms'}`,
      startDate: startDate ? new Date(startDate) : new Date(),
      trustScore: 0.0, // Default trust score
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
    };

    console.log('Creating campaign with data:', campaignData);

    // Create the campaign with metadata
    const campaign = await prisma.campaign.create({
      data: campaignData,
    });

    console.log('Campaign created successfully:', campaign.id);

    // Create agents for the campaign
    console.log('=== STARTING AGENT CREATION ===');
    const { createdAgents, errors } = await createCampaignAgents(campaign.id, metadata);
    
    if (errors.length > 0) {
      console.warn('Some agents failed to create:', errors);
    }

    // Log the campaign creation for debugging
    console.log('=== CAMPAIGN CREATION LOG ===');
    console.log('Campaign ID:', campaign.id);
    console.log('Campaign Name:', campaign.name);
    console.log('Campaign Hashtag:', campaign.hashtag);
    console.log('Campaign Description:', campaign.description);
    console.log('Start Date:', campaign.startDate);
    console.log('Trust Score:', campaign.trustScore);
    console.log('Created At:', campaign.createdAt);
    console.log('Updated At:', campaign.updatedAt);
    
    // Log metadata details
    console.log('=== METADATA DETAILS ===');
    console.log('Selected Platforms:', metadata?.platforms);
    console.log('Keywords:', metadata?.keywords);
    console.log('Hashtags:', metadata?.hashtags);
    console.log('Spam Threshold:', metadata?.spamThreshold);
    console.log('Sentiment Threshold:', metadata?.sentimentThreshold);
    console.log('Generated Crawler Agents:', crawlerAgents);
    console.log('Consensus Agent Count:', consensusAgentCount);
    console.log('Fixed Analyzers:', fixedAnalyzers);
    console.log('Budget:', metadata?.budget);
    console.log('Wallet Address:', metadata?.walletAddress);
    console.log('JuliaOS Account:', metadata?.juliaOSAccount);
    
    // Log agent details
    console.log('=== AGENT DETAILS ===');
    console.log('Total Agents:', totalAgents);
    console.log('Crawler Agents:', crawlerAgents);
    console.log('Consensus Agents:', consensusAgentCount);
    console.log('Fixed Analyzers:', fixedAnalyzers);
    console.log('Agent Details:', {
      crawlers: crawlerAgents,
      consensus: consensusAgentCount,
      fixedAnalyzers: fixedAnalyzers,
      total: totalAgents
    });
    
    // Log agent creation results
    console.log('=== AGENT CREATION RESULTS ===');
    console.log('Created Agents:', createdAgents.length);
    console.log('Agent Errors:', errors.length);
    console.log('Agent Types Created:', createdAgents.map(a => a.type));
    
    console.log('=== END CAMPAIGN LOG ===');

    // Return campaign with agent creation results
    return NextResponse.json({
      ...campaign,
      agentCreation: {
        createdAgents: createdAgents.length,
        errors: errors.length,
        agentDetails: createdAgents.map(a => ({ id: a.id, name: a.name, type: a.type })),
        errorDetails: errors
      }
    });
    
  } catch (error) {
    console.error('Error creating campaign:', error);
    console.error('Error details:', {
      message: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
      name: error instanceof Error ? error.name : undefined
    });
    return NextResponse.json(
      { 
        error: 'Failed to create campaign',
        details: error instanceof Error ? error.message : 'Unknown error'
      }, 
      { status: 500 }
    );
  }
} 