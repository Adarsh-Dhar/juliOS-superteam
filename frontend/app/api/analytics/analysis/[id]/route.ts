import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8053/api/v1';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    
    // Get campaign posts for analysis
    const posts = await prisma.post.findMany({
      where: { campaignId },
      orderBy: { createdAt: 'desc' }
    });

    // Fetch analysis data from Julia
    const analysisData = await fetchJuliaAnalysisData(campaignId);

    // Calculate basic engagement metrics
    const totalEngagement = posts.reduce((sum, post) => 
      sum + post.likes + post.comments + post.shares, 0
    );
    
    const averageEngagement = posts.length > 0 ? totalEngagement / posts.length : 0;

    const analytics = {
      // Sentiment Analysis
      sentiment: {
        positive: analysisData.sentiment?.positive || 0,
        negative: analysisData.sentiment?.negative || 0,
        neutral: analysisData.sentiment?.neutral || 0,
        trend: analysisData.sentiment?.trend || [],
        breakdown: posts.map(post => ({
          id: post.id,
          content: post.content,
          sentiment: analysisData.sentiment?.postSentiment?.[post.id] || 'neutral',
          engagement: post.likes + post.comments + post.shares
        }))
      },

      // Trend Analysis
      trends: {
        keywords: analysisData.trends?.keywords || [],
        hashtags: analysisData.trends?.hashtags || [],
        topics: analysisData.trends?.topics || [],
        trendData: analysisData.trends?.trendData || [],
        topTrending: analysisData.trends?.topTrending || []
      },

      // Engagement Analysis
      engagement: {
        total: totalEngagement,
        average: averageEngagement,
        rate: posts.length > 0 ? (totalEngagement / posts.length) * 100 : 0,
        breakdown: {
          likes: posts.reduce((sum, post) => sum + post.likes, 0),
          comments: posts.reduce((sum, post) => sum + post.comments, 0),
          shares: posts.reduce((sum, post) => sum + post.shares, 0)
        },
        byPlatform: posts.reduce((acc, post) => {
          const platform = post.platform;
          if (!acc[platform]) {
            acc[platform] = { posts: 0, engagement: 0, avgEngagement: 0 };
          }
          acc[platform].posts++;
          acc[platform].engagement += post.likes + post.comments + post.shares;
          acc[platform].avgEngagement = acc[platform].engagement / acc[platform].posts;
          return acc;
        }, {} as Record<string, any>)
      },

      // Content Analysis
      content: {
        totalPosts: posts.length,
        averageLength: posts.length > 0 ? 
          posts.reduce((sum, post) => sum + post.content.length, 0) / posts.length : 0,
        mediaPosts: posts.filter(post => post.mediaUrl).length,
        textOnlyPosts: posts.filter(post => !post.mediaUrl).length
      },

      // Julia Analysis Data
      juliaData: {
        sentimentAnalysis: analysisData.sentimentAnalysis || {},
        trendAnalysis: analysisData.trendAnalysis || {},
        keywordExtraction: analysisData.keywordExtraction || [],
        topicModeling: analysisData.topicModeling || []
      },

      // Timeline Analysis
      timeline: {
        sentiment: analysisData.timelineSentiment || [],
        engagement: analysisData.timelineEngagement || [],
        trends: analysisData.timelineTrends || []
      }
    };

    return NextResponse.json(analytics);
  } catch (error) {
    console.error('Error fetching analysis analytics:', error);
    return NextResponse.json(
      { error: 'Failed to fetch analysis analytics' },
      { status: 500 }
    );
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