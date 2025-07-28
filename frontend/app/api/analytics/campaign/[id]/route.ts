import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// Julia backend API base URL
const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8053/api/v1';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    
    // Get campaign details from database
    const campaign = await prisma.campaign.findUnique({
      where: { id: campaignId },
      include: {
        posts: true,
        AnalyticsSnapshot: true,
      }
    });

    if (!campaign) {
      return NextResponse.json({ error: 'Campaign not found' }, { status: 404 });
    }

    // Fetch data from Julia agents
    const [crawlerData, analysisData, consensusData] = await Promise.all([
      fetchJuliaCrawlerData(campaignId),
      fetchJuliaAnalysisData(campaignId),
      fetchJuliaConsensusData(campaignId)
    ]);

    // Compile comprehensive analytics
    const analytics = {
      campaign: {
        id: campaign.id,
        name: campaign.name,
        hashtag: campaign.hashtag,
        description: campaign.description,
        startDate: campaign.startDate,
        endDate: campaign.endDate,
        trustScore: campaign.trustScore,
        status: campaign.endDate ? 'completed' : 'active'
      },
      
      // Crawler Analytics
      crawler: {
        totalPosts: crawlerData.totalPosts || campaign.posts.length,
        platforms: crawlerData.platforms || [],
        recentActivity: crawlerData.recentActivity || [],
        crawlStats: {
          twitter: crawlerData.twitterStats || { posts: 0, engagement: 0 },
          reddit: crawlerData.redditStats || { posts: 0, engagement: 0 },
          total: crawlerData.totalStats || { posts: 0, engagement: 0 }
        },
        agentStatus: crawlerData.agentStatus || []
      },

      // Analysis Analytics
      analysis: {
        sentiment: analysisData.sentiment || {
          positive: 0,
          negative: 0,
          neutral: 0,
          trend: []
        },
        trends: analysisData.trends || {
          keywords: [],
          hashtags: [],
          topics: [],
          trendData: []
        },
        engagement: analysisData.engagement || {
          total: 0,
          rate: 0,
          breakdown: []
        }
      },

      // Consensus Analytics
      consensus: {
        totalAgents: consensusData.totalAgents || 0,
        activeAgents: consensusData.activeAgents || 0,
        consensusScore: consensusData.consensusScore || 0,
        verificationResults: consensusData.verificationResults || [],
        agentPerformance: consensusData.agentPerformance || []
      },

      // Performance Metrics
      performance: {
        totalEngagement: (crawlerData.totalStats?.engagement || 0) + (analysisData.engagement?.total || 0),
        averageResponseTime: crawlerData.averageResponseTime || 0,
        reach: crawlerData.reach || 0,
        impressions: crawlerData.impressions || 0,
        uniqueUsers: crawlerData.uniqueUsers || 0
      },

      // Timeline Data
      timeline: {
        posts: crawlerData.timelinePosts || [],
        engagement: analysisData.timelineEngagement || [],
        sentiment: analysisData.timelineSentiment || []
      }
    };

    return NextResponse.json(analytics);
  } catch (error) {
    console.error('Error fetching campaign analytics:', error);
    return NextResponse.json(
      { error: 'Failed to fetch analytics' },
      { status: 500 }
    );
  }
}

// Helper functions to fetch data from Julia agents
async function fetchJuliaCrawlerData(campaignId: string) {
  try {
    const response = await fetch(`${JULIA_API_BASE}/crawlers/campaign/${campaignId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (!response.ok) {
      console.warn('Failed to fetch crawler data from Julia');
      return {};
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Error fetching crawler data:', error);
    return {};
  }
}

async function fetchJuliaAnalysisData(campaignId: string) {
  try {
    const response = await fetch(`${JULIA_API_BASE}/analysis/campaign/${campaignId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (!response.ok) {
      console.warn('Failed to fetch analysis data from Julia');
      return {};
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Error fetching analysis data:', error);
    return {};
  }
}

async function fetchJuliaConsensusData(campaignId: string) {
  try {
    const response = await fetch(`${JULIA_API_BASE}/consensus/campaign/${campaignId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (!response.ok) {
      console.warn('Failed to fetch consensus data from Julia');
      return {};
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Error fetching consensus data:', error);
    return {};
  }
} 