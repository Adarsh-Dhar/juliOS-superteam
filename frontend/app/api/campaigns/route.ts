import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

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
    
    console.log('=== END CAMPAIGN LOG ===');

    return NextResponse.json(campaign);
    
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