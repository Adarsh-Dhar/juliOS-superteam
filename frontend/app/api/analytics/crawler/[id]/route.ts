import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8055/api/v1';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    
    // Get campaign posts
    const posts = await prisma.post.findMany({
      where: { campaignId },
      orderBy: { createdAt: 'desc' },
      take: 100
    });

    // Fetch crawler data from Julia
    const crawlerData = await fetchJuliaCrawlerData(campaignId);

    const analytics = {
      totalPosts: posts.length,
      platforms: [...new Set(posts.map(p => p.platform))],
      recentPosts: posts.slice(0, 10).map(post => ({
        id: post.id,
        content: post.content,
        platform: post.platform,
        engagement: post.likes + post.comments + post.shares,
        createdAt: post.createdAt
      })),
      
      // Platform breakdown
      platformStats: posts.reduce((acc, post) => {
        const platform = post.platform;
        if (!acc[platform]) {
          acc[platform] = { posts: 0, engagement: 0, likes: 0, comments: 0, shares: 0 };
        }
        acc[platform].posts++;
        acc[platform].engagement += post.likes + post.comments + post.shares;
        acc[platform].likes += post.likes;
        acc[platform].comments += post.comments;
        acc[platform].shares += post.shares;
        return acc;
      }, {} as Record<string, any>),

      // Julia crawler data
      juliaData: {
        twitterStats: crawlerData.twitterStats || { posts: 0, engagement: 0, reach: 0 },
        redditStats: crawlerData.redditStats || { posts: 0, engagement: 0, reach: 0 },
        agentStatus: crawlerData.agentStatus || [],
        recentActivity: crawlerData.recentActivity || [],
        averageResponseTime: crawlerData.averageResponseTime || 0
      },

      // Timeline data
      timeline: posts.map(post => ({
        date: post.createdAt,
        posts: 1,
        engagement: post.likes + post.comments + post.shares,
        platform: post.platform
      }))
    };

    return NextResponse.json(analytics);
  } catch (error) {
    console.error('Error fetching crawler analytics:', error);
    return NextResponse.json(
      { error: 'Failed to fetch crawler analytics' },
      { status: 500 }
    );
  }
}

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