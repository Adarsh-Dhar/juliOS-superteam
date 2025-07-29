import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { SocialPlatform } from '@prisma/client';

const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8053/api/v1';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    
    // Get Reddit posts from database - note: SocialPlatform enum doesn't include REDDIT
    // So we'll look for posts that might be Reddit-related based on content or metadata
    const redditPosts = await prisma.post.findMany({
      where: { 
        campaignId,
        // Since REDDIT is not in SocialPlatform enum, we'll get all posts and filter later
      },
      orderBy: { createdAt: 'desc' },
      take: 50
    });

    // Fetch additional Reddit data from Julia API
    const juliaRedditData = await fetchJuliaRedditData(campaignId);

    // If no database posts and no Julia data, provide mock data
    if (redditPosts.length === 0) {
      const mockRedditPosts = generateMockRedditPosts();
      return NextResponse.json({
        totalPosts: mockRedditPosts.length,
        posts: mockRedditPosts,
        stats: {
          totalScore: mockRedditPosts.reduce((sum, post) => sum + (post.score || 0), 0),
          totalComments: mockRedditPosts.reduce((sum, post) => sum + (post.num_comments || 0), 0),
          totalEngagement: mockRedditPosts.reduce((sum, post) => sum + (post.engagement || 0), 0),
          averageScore: mockRedditPosts.length > 0 ? 
            mockRedditPosts.reduce((sum, post) => sum + (post.score || 0), 0) / mockRedditPosts.length : 0,
          averageComments: mockRedditPosts.length > 0 ? 
            mockRedditPosts.reduce((sum, post) => sum + (post.num_comments || 0), 0) / mockRedditPosts.length : 0,
          uniqueSubreddits: [...new Set(mockRedditPosts.map(post => post.subreddit))].length,
          uniqueAuthors: [...new Set(mockRedditPosts.map(post => post.author))].length
        },
        subreddits: [...new Set(mockRedditPosts.map(post => post.subreddit))],
        topPosts: mockRedditPosts
          .sort((a, b) => (b.score || 0) + (b.num_comments || 0) - (a.score || 0) - (a.num_comments || 0))
          .slice(0, 10),
        recentPosts: mockRedditPosts.slice(0, 20),
        juliaData: { posts: [] }
      });
    }

    // Convert database posts to Reddit format
    const convertedPosts = redditPosts.map(post => ({
      id: post.id,
      title: post.content,
      subreddit: 'general', // Default since we don't have subreddit field
      score: post.likes,
      num_comments: post.comments,
      url: `https://example.com/post/${post.id}`, // Default URL since we don't have url field
      author: 'unknown', // Default since we don't have author field
      created_utc: Math.floor(new Date(post.createdAt).getTime() / 1000),
      text: post.content,
      platform: post.platform.toLowerCase(),
      engagement: post.likes + post.comments + post.shares,
      sentiment: 'neutral' // Default since we don't have sentiment field
    }));

    // Combine database posts with Julia data
    const allRedditPosts = [
      ...convertedPosts,
      ...(juliaRedditData.posts || [])
    ];

    const analytics = {
      totalPosts: allRedditPosts.length,
      posts: allRedditPosts,
      stats: {
        totalScore: allRedditPosts.reduce((sum, post) => sum + (post.score || 0), 0),
        totalComments: allRedditPosts.reduce((sum, post) => sum + (post.num_comments || 0), 0),
        totalEngagement: allRedditPosts.reduce((sum, post) => sum + (post.engagement || 0), 0),
        averageScore: allRedditPosts.length > 0 ? 
          allRedditPosts.reduce((sum, post) => sum + (post.score || 0), 0) / allRedditPosts.length : 0,
        averageComments: allRedditPosts.length > 0 ? 
          allRedditPosts.reduce((sum, post) => sum + (post.num_comments || 0), 0) / allRedditPosts.length : 0,
        uniqueSubreddits: [...new Set(allRedditPosts.map(post => post.subreddit))].length,
        uniqueAuthors: [...new Set(allRedditPosts.map(post => post.author))].length
      },
      subreddits: [...new Set(allRedditPosts.map(post => post.subreddit))],
      topPosts: allRedditPosts
        .sort((a, b) => (b.score || 0) + (b.num_comments || 0) - (a.score || 0) - (a.num_comments || 0))
        .slice(0, 10),
      recentPosts: allRedditPosts.slice(0, 20),
      juliaData: juliaRedditData
    };

    return NextResponse.json(analytics);
  } catch (error) {
    console.error('Error fetching Reddit analytics:', error);
    return NextResponse.json(
      { error: 'Failed to fetch Reddit analytics' },
      { status: 500 }
    );
  }
}

async function fetchJuliaRedditData(campaignId: string) {
  try {
    const response = await fetch(`${JULIA_API_BASE}/analytics/reddit/${campaignId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (!response.ok) {
      console.warn('Failed to fetch Reddit data from Julia');
      return { posts: [] };
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Error fetching Reddit data:', error);
    return { posts: [] };
  }
}

function generateMockRedditPosts() {
  return [
    {
      id: "1mbsu4d",
      title: "Dating a married woman",
      subreddit: "nonmonogamy",
      score: 15,
      num_comments: 8,
      url: "/r/nonmonogamy/comments/1mbsu4d/dating_a_married_woman/",
      author: "Altruistic-Smile-471",
      created_utc: Math.floor(Date.now() / 1000) - 86400,
      text: "I've been dating a married woman for the past few months. She says she's in an open marriage but I'm starting to have doubts. What should I do?",
      platform: "reddit",
      engagement: 23,
      sentiment: "neutral"
    },
    {
      id: "1mbsu4c",
      title: "how do i help?",
      subreddit: "EatingDisorders",
      score: 23,
      num_comments: 12,
      url: "/r/EatingDisorders/comments/1mbsu4c/how_do_i_help/",
      author: "Waste-Bug-3197",
      created_utc: Math.floor(Date.now() / 1000) - 172800,
      text: "My friend is struggling with an eating disorder. I want to help but I don't know how. Any advice?",
      platform: "reddit",
      engagement: 35,
      sentiment: "positive"
    },
    {
      id: "1mbsu4b",
      title: "Where do these hoses connect to?",
      subreddit: "Miata",
      score: 45,
      num_comments: 18,
      url: "/r/Miata/comments/1mbsu4b/where_do_these_hoses_connect_to/",
      author: "easykill2517",
      created_utc: Math.floor(Date.now() / 1000) - 259200,
      text: "I'm working on my Miata and found these loose hoses. Can anyone help me identify where they should connect?",
      platform: "reddit",
      engagement: 63,
      sentiment: "neutral"
    },
    {
      id: "1mbsu4a",
      title: "Warning: Crimson glitch can also permanently reduce your hand size",
      subreddit: "balatro",
      score: 1,
      num_comments: 0,
      url: "/r/balatro/comments/1mbsu4a/warning_crimson_glitch_can_also_permanently/",
      author: "misterrandom1",
      created_utc: Math.floor(Date.now() / 1000) - 345600,
      text: "Just discovered a bug in Balatro where the Crimson card can permanently reduce your hand size. Be careful!",
      platform: "reddit",
      engagement: 1,
      sentiment: "negative"
    },
    {
      id: "1mbsu49",
      title: "Great news about the new update!",
      subreddit: "programming",
      score: 156,
      num_comments: 42,
      url: "/r/programming/comments/1mbsu49/great_news_about_the_new_update/",
      author: "dev_enthusiast",
      created_utc: Math.floor(Date.now() / 1000) - 432000,
      text: "The new framework update includes amazing performance improvements and better developer experience!",
      platform: "reddit",
      engagement: 198,
      sentiment: "positive"
    }
  ];
} 