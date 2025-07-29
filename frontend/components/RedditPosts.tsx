"use client";

import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  MessageSquare,
  ArrowUp,
  MessageCircle,
  Activity,
  ExternalLink,
  User,
  Loader2,
  AlertCircle
} from "lucide-react";

interface RedditPost {
  id: string;
  title: string;
  subreddit: string;
  score: number;
  num_comments: number;
  url: string;
  author: string;
  created_utc: number;
  text: string;
  platform: string;
  engagement: number;
  sentiment?: string;
}

interface RedditData {
  totalPosts: number;
  posts: RedditPost[];
  stats: {
    totalScore: number;
    totalComments: number;
    totalEngagement: number;
    averageScore: number;
    averageComments: number;
    uniqueSubreddits: number;
    uniqueAuthors: number;
  };
  subreddits: string[];
  topPosts: RedditPost[];
  recentPosts: RedditPost[];
  juliaData: any;
}

interface RedditPostsProps {
  campaignId: string;
}

export default function RedditPosts({ campaignId }: RedditPostsProps) {
  const [redditData, setRedditData] = useState<RedditData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchRedditPosts();
  }, [campaignId]);

  const fetchRedditPosts = async () => {
    try {
      setLoading(true);
      setError(null);

      console.log('🔍 Fetching Reddit posts for campaign:', campaignId);
      
      const response = await fetch(`/api/analytics/reddit/${campaignId}`);
      if (!response.ok) {
        throw new Error("Failed to fetch Reddit posts");
      }

      const data = await response.json();
      console.log('📊 Reddit data received:', data);
      console.log('📝 Total Reddit posts:', data.totalPosts);
      console.log('📊 Reddit stats:', data.stats);
      
      setRedditData(data);
    } catch (err: any) {
      console.error('❌ Error fetching Reddit posts:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getSentimentColor = (sentiment?: string) => {
    switch (sentiment?.toLowerCase()) {
      case 'positive': return 'text-green-400';
      case 'negative': return 'text-red-400';
      case 'neutral': return 'text-gray-400';
      default: return 'text-gray-400';
    }
  };

  const getSentimentIcon = (sentiment?: string) => {
    switch (sentiment?.toLowerCase()) {
      case 'positive': return '😊';
      case 'negative': return '😞';
      case 'neutral': return '😐';
      default: return '😐';
    }
  };

  if (loading) {
    return (
      <div className="text-center py-8">
        <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-blue-400" />
        <p className="text-gray-400 font-exo2">Loading Reddit posts...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-8">
        <AlertCircle className="w-12 h-12 text-red-400 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-white mb-2 font-orbitron">
          Error Loading Reddit Posts
        </h3>
        <p className="text-gray-400 mb-4 font-exo2">{error}</p>
        <Button onClick={fetchRedditPosts} className="bg-gradient-to-r from-purple-500 to-blue-500">
          Retry
        </Button>
      </div>
    );
  }

  if (!redditData || redditData.posts.length === 0) {
    return (
      <div className="text-center py-8">
        <MessageSquare className="w-12 h-12 text-gray-500 mx-auto mb-4" />
        <p className="text-gray-400 font-exo2">No Reddit posts found for this campaign</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Reddit Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <Card className="glassmorphism border-red-500/20">
          <CardContent className="p-4">
            <div className="flex items-center">
              <div className="p-2 bg-red-500/20 rounded-lg mr-3">
                <MessageSquare className="w-5 h-5 text-red-400" />
              </div>
              <div>
                <div className="text-2xl font-bold text-white">
                  {redditData.totalPosts}
                </div>
                <div className="text-sm text-gray-400 font-exo2">Reddit Posts</div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="glassmorphism border-blue-500/20">
          <CardContent className="p-4">
            <div className="flex items-center">
              <div className="p-2 bg-blue-500/20 rounded-lg mr-3">
                <ArrowUp className="w-5 h-5 text-blue-400" />
              </div>
              <div>
                <div className="text-2xl font-bold text-white">
                  {redditData.stats.totalScore.toLocaleString()}
                </div>
                <div className="text-sm text-gray-400 font-exo2">Total Score</div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="glassmorphism border-green-500/20">
          <CardContent className="p-4">
            <div className="flex items-center">
              <div className="p-2 bg-green-500/20 rounded-lg mr-3">
                <MessageCircle className="w-5 h-5 text-green-400" />
              </div>
              <div>
                <div className="text-2xl font-bold text-white">
                  {redditData.stats.totalComments.toLocaleString()}
                </div>
                <div className="text-sm text-gray-400 font-exo2">Total Comments</div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="glassmorphism border-purple-500/20">
          <CardContent className="p-4">
            <div className="flex items-center">
              <div className="p-2 bg-purple-500/20 rounded-lg mr-3">
                <User className="w-5 h-5 text-purple-400" />
              </div>
              <div>
                <div className="text-2xl font-bold text-white">
                  {redditData.stats.uniqueSubreddits}
                </div>
                <div className="text-sm text-gray-400 font-exo2">Subreddits</div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Reddit Posts List */}
      <Card className="glassmorphism border-red-500/20">
        <CardHeader>
          <CardTitle className="flex items-center text-white font-orbitron">
            <MessageSquare className="w-5 h-5 mr-2 text-red-400" />
            Reddit Posts ({redditData.totalPosts})
          </CardTitle>
          <CardDescription className="text-gray-400 font-exo2">
            Recent Reddit posts from monitored subreddits
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {redditData.recentPosts.map((post, index) => (
              <motion.div
                key={post.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.3, delay: index * 0.1 }}
                className="p-4 border border-gray-600/50 rounded-lg bg-gray-800/30 hover:bg-gray-800/50 transition-colors"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <Badge variant="outline" className="text-xs border-red-500/30 text-red-400 bg-red-500/10">
                        r/{post.subreddit}
                      </Badge>
                      <span className="text-xs text-gray-400 font-exo2">
                        by {post.author}
                      </span>
                      <span className="text-xs text-gray-500 font-exo2">
                        {formatDate(post.created_utc)}
                      </span>
                    </div>
                    <h3 className="text-white font-medium mb-2 font-exo2">
                      {post.title}
                    </h3>
                    {post.text && post.text !== post.title && (
                      <p className="text-gray-400 text-sm mb-3 font-exo2 line-clamp-2">
                        {post.text}
                      </p>
                    )}
                  </div>
                  <div className="flex items-center space-x-1 ml-4">
                    <span className={`text-sm ${getSentimentColor(post.sentiment)}`}>
                      {getSentimentIcon(post.sentiment)}
                    </span>
                  </div>
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4 text-sm text-gray-400">
                    <div className="flex items-center space-x-1">
                      <ArrowUp className="w-4 h-4" />
                      <span className="font-exo2">{post.score}</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <MessageCircle className="w-4 h-4" />
                      <span className="font-exo2">{post.num_comments}</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Activity className="w-4 h-4" />
                      <span className="font-exo2">{post.engagement}</span>
                    </div>
                  </div>
                  <Button
                    size="sm"
                    variant="outline"
                    className="border-gray-600 text-gray-300 hover:bg-gray-800"
                    onClick={() => window.open(post.url, '_blank')}
                  >
                    <ExternalLink className="w-4 h-4 mr-1" />
                    View
                  </Button>
                </div>
              </motion.div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
} 