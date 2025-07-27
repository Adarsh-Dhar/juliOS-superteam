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

    // For now, return a mock response to test the API routing
    const mockCampaign = {
      id: `camp_${Date.now()}`,
      name,
      hashtag,
      description: description || `Campaign monitoring ${metadata?.platforms?.join(', ') || 'various platforms'}`,
      startDate: startDate ? new Date(startDate) : new Date(),
      trustScore: 0.0,
      createdAt: new Date(),
      updatedAt: new Date(),
      metadata: metadata
    };

    console.log('Mock campaign created:', mockCampaign);

    return NextResponse.json(mockCampaign);
    
    /* 
    // Uncomment this when database is ready
    // Check if campaign with this hashtag already exists
    const existingCampaign = await prisma.campaign.findUnique({
      where: { hashtag },
    });

    if (existingCampaign) {
      return NextResponse.json({ error: 'Campaign with this hashtag already exists' }, { status: 409 });
    }

    // Create the campaign
    const campaign = await prisma.campaign.create({
      data: {
        name,
        hashtag,
        description: description || `Campaign monitoring ${metadata?.platforms?.join(', ') || 'various platforms'}`,
        startDate: startDate ? new Date(startDate) : new Date(),
        trustScore: 0.0, // Default trust score
      },
    });

    // Log the campaign creation for debugging
    console.log('Campaign created:', {
      id: campaign.id,
      name: campaign.name,
      hashtag: campaign.hashtag,
      metadata: metadata
    });

    return NextResponse.json({
      ...campaign,
      metadata: metadata // Include metadata in response for confirmation
    });
    */
    
  } catch (error) {
    console.error('Error creating campaign:', error);
    return NextResponse.json(
      { error: 'Failed to create campaign' }, 
      { status: 500 }
    );
  }
} 