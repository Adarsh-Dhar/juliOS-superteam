import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    console.log('🚀 Analytics API called for campaign:', campaignId);
    
    // Get campaign details from database
    const campaign = await prisma.campaign.findUnique({
      where: { id: campaignId },
      include: {
        posts: true,
        AnalyticsSnapshot: true,
      }
    });

    if (!campaign) {
      console.log('❌ Campaign not found:', campaignId);
      return NextResponse.json({ error: 'Campaign not found' }, { status: 404 });
    }

    console.log('📋 Campaign found:', {
      id: campaign.id,
      name: campaign.name,
      hashtag: campaign.hashtag,
      postsCount: campaign.posts.length
    });

    // Use the working sentiment analysis route instead of Julia server
    console.log('🔄 Fetching data from local analytics...');
    
    // Get sentiment data from our working route
    const sentimentResponse = await fetch(`${req.nextUrl.origin}/api/analytics`);
    const sentimentData = await sentimentResponse.json();
    
    // Create mock data for other analytics
    const crawlerData = {
      total_analyzed: 5,
      results: [
        { id: "1", platform: "reddit", engagement: 15, sentiment: "positive" },
        { id: "2", platform: "reddit", engagement: 8, sentiment: "negative" },
        { id: "3", platform: "reddit", engagement: 23, sentiment: "neutral" }
      ]
    };
    
    const consensusData = {
      agents: [
        { id: "agent_1", reputation: 85.2, stake: 0.12, total_verifications: 5 },
        { id: "agent_2", reputation: 78.9, stake: 0.08, total_verifications: 4 }
      ],
      consensus_results: [
        { post_id: "1", consensus: { bot: false, manip: false, auth: true, confidence: 0.85 } },
        { post_id: "2", consensus: { bot: false, manip: true, auth: false, confidence: 0.72 } }
      ]
    };

    console.log('📊 Analytics data received:', {
      crawler: crawlerData,
      analysis: sentimentData.sentiment,
      consensus: consensusData
    });

    // Compile final analytics
    const finalAnalytics = {
      campaign: {
        id: campaign.id,
        name: campaign.name,
        hashtag: campaign.hashtag,
        description: campaign.description || '',
        startDate: campaign.createdAt.toISOString(),
        endDate: campaign.updatedAt.toISOString(),
        trustScore: 85.5,
        status: 'active' // Default status since it's not in the database
      },
      crawler: {
        totalPosts: sentimentData.sentiment.total_analyzed || 0,
        platforms: ['reddit', 'twitter'],
        recentActivity: crawlerData.results,
        crawlStats: {
          twitter: { posts: 2, engagement: 45 },
          reddit: { posts: 3, engagement: 46 },
          total: { posts: 5, engagement: 91 }
        },
        agentStatus: [
          { id: 'agent_1', status: 'active', lastSeen: new Date().toISOString() },
          { id: 'agent_2', status: 'active', lastSeen: new Date().toISOString() }
        ]
      },
      analysis: {
        sentiment: {
          positive: sentimentData.sentiment.positive || 0,
          negative: sentimentData.sentiment.negative || 0,
          neutral: sentimentData.sentiment.neutral || 0,
          trend: []
        },
        trends: {
          keywords: ['keyword1', 'keyword2'],
          hashtags: ['#hashtag1', '#hashtag2'],
          topics: ['topic1', 'topic2'],
          trendData: []
        },
        engagement: {
          total: crawlerData.total_analyzed * 10,
          rate: 85.5,
          breakdown: []
        }
      },
      consensus: {
        totalAgents: consensusData.agents.length,
        activeAgents: consensusData.agents.length,
        consensusScore: 0.85,
        verificationResults: consensusData.consensus_results,
        agentPerformance: consensusData.agents
      },
      performance: {
        totalEngagement: crawlerData.total_analyzed * 10,
        averageResponseTime: 2.5,
        reach: 1500,
        impressions: 3000,
        uniqueUsers: 750
      },
      timeline: {
        posts: [],
        engagement: [],
        sentiment: []
      }
    };

    console.log('✅ Final analytics compiled:', {
      campaignId: finalAnalytics.campaign.id,
      totalPosts: finalAnalytics.crawler.totalPosts,
      totalEngagement: finalAnalytics.performance.totalEngagement,
      totalAgents: finalAnalytics.consensus.totalAgents
    });

    return NextResponse.json(finalAnalytics, {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
      }
    });
    
  } catch (error) {
    console.error('❌ Error in analytics API:', error);
    
    return NextResponse.json({
      error: 'Failed to fetch analytics',
      message: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    }, {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
} 