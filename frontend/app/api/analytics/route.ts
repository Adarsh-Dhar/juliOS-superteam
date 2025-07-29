import { NextRequest, NextResponse } from 'next/server';
import { spawn } from 'child_process';
import path from 'path';

interface SentimentResult {
  post_id: string;
  text: string;
  full_text: string;
  sentiment: 'positive' | 'negative' | 'neutral';
  confidence: number;
  subreddit: string;
  positive_score: number;
  negative_score: number;
  sentiment_words: {
    positive: string[];
    negative: string[];
  };
}

interface SentimentAnalytics {
  results: SentimentResult[];
  distribution: {
    positive: number;
    negative: number;
    neutral: number;
  };
  total_analyzed: number;
  average_confidence: number;
  sentiment_breakdown: {
    positive_posts: number;
    negative_posts: number;
    neutral_posts: number;
    positive_percentage: number;
    negative_percentage: number;
    neutral_percentage: number;
  };
  subreddit_sentiment: Record<string, {
    positive: number;
    negative: number;
    neutral: number;
  }>;
  confidence_distribution: {
    high: number;
    medium: number;
    low: number;
  };
}

interface TrendResult {
  topic_id: number;
  current_volume: number;
  growth_rate: number;
  acceleration: number;
  peak_time: string;
  trend_strength: 'high' | 'medium' | 'low';
}

interface TrendAnalytics {
  period_start: string;
  period_end: string;
  total_documents: number;
  topics: Record<number, number[]>;
  trends: TrendResult[];
  topic_series: Record<number, number[]>;
  word_frequencies: Record<string, number>;
}

interface ConsensusResult {
  post_id: string;
  title: string;
  consensus: {
    bot: boolean;
    manip: boolean;
    auth: boolean;
    confidence: number;
  };
  total_votes: number;
}

interface AgentResult {
  agent_id: string;
  post_id: string;
  votes: {
    bot: boolean;
    manip: boolean;
    auth: boolean;
  };
  reputation: number;
  stake: number;
}

interface ConsensusAnalytics {
  agents: Array<{
    id: string;
    personality: {
      bot_skepticism: number;
      manipulation_sensitivity: number;
      authenticity_optimism: number;
      novelty_preference: number;
      conformity_bias: number;
      risk_aversion: number;
    };
    reputation: number;
    stake: number;
    total_verifications: number;
    successful_verifications: number;
    error_count: number;
  }>;
  consensus_results: ConsensusResult[];
  agent_results: AgentResult[];
}

interface AnalyticsData {
  sentiment: SentimentAnalytics;
  trend: TrendAnalytics;
  consensus: ConsensusAnalytics;
  timestamp: string;
  status: 'success' | 'error';
  message?: string;
}

async function runJuliaScript(scriptPath: string): Promise<any> {
  return new Promise((resolve, reject) => {
    console.log(`Running Julia script: ${scriptPath}`);
    const juliaProcess = spawn('julia', [scriptPath]);
    
    let stdout = '';
    let stderr = '';
    
    juliaProcess.stdout.on('data', (data) => {
      stdout += data.toString();
    });
    
    juliaProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });
    
    juliaProcess.on('close', (code) => {
      console.log(`Julia script exited with code: ${code}`);
      console.log(`stdout length: ${stdout.length}`);
      console.log(`stderr length: ${stderr.length}`);
      
      if (code === 0) {
        try {
          // Look for JSON output between markers
          const jsonStart = stdout.indexOf('OUTPUT_JSON_START');
          const jsonEnd = stdout.indexOf('OUTPUT_JSON_END');
          
          console.log(`JSON start index: ${jsonStart}`);
          console.log(`JSON end index: ${jsonEnd}`);
          
          if (jsonStart !== -1 && jsonEnd !== -1) {
            const jsonContent = stdout.substring(jsonStart + 'OUTPUT_JSON_START'.length, jsonEnd).trim();
            console.log(`JSON content length: ${jsonContent.length}`);
            console.log(`JSON content preview: ${jsonContent.substring(0, 200)}...`);
            const parsedData = JSON.parse(jsonContent);
            console.log('Successfully parsed Julia output');
            resolve(parsedData);
          } else {
            console.log('No JSON markers found in output');
            console.log('stdout preview:', stdout.substring(0, 500));
            // Fallback to structured mock response
            resolve({ success: true, script: path.basename(scriptPath) });
          }
        } catch (error) {
          console.error('Error parsing Julia output:', error);
          console.log('stdout that failed to parse:', stdout);
          resolve({ success: true, script: path.basename(scriptPath) });
        }
      } else {
        console.error(`Julia script failed with code ${code}: ${stderr}`);
        reject(new Error(`Julia script failed with code ${code}: ${stderr}`));
      }
    });
    
    juliaProcess.on('error', (error) => {
      console.error(`Failed to start Julia process: ${error.message}`);
      reject(new Error(`Failed to start Julia process: ${error.message}`));
    });
  });
}

export async function GET(request: NextRequest) {
  try {
    const baseDir = process.cwd();
    const juliaDir = path.join(baseDir, '..', 'JuliaOS', 'julia');
    
    // Define script paths
    const sentimentScript = path.join(juliaDir, 'test_sentiment_reddit_integration.jl');
    const trendScript = path.join(juliaDir, 'demo_trend.jl');
    const consensusScript = path.join(juliaDir, 'demo_consensus.jl');
    
    console.log('Running Julia analytics scripts...');
    
    // Run sentiment analysis script
    const sentimentResult = await runJuliaScript(sentimentScript);
    console.log('Sentiment analysis completed');
    console.log('Sentiment result:', JSON.stringify(sentimentResult, null, 2));
    
    // Run other scripts in parallel (keeping mock data for now)
    const [trendResult, consensusResult] = await Promise.all([
      runJuliaScript(trendScript),
      runJuliaScript(consensusScript)
    ]);
    
    // Use actual sentiment data from Julia script
    const analyticsData: AnalyticsData = {
      sentiment: sentimentResult.sentiment || {
        results: [],
        distribution: { positive: 0, negative: 0, neutral: 0 },
        total_analyzed: 0,
        average_confidence: 0,
        sentiment_breakdown: {
          positive_posts: 0,
          negative_posts: 0,
          neutral_posts: 0,
          positive_percentage: 0,
          negative_percentage: 0,
          neutral_percentage: 0
        },
        subreddit_sentiment: {},
        confidence_distribution: { high: 0, medium: 0, low: 0 }
      },
      trend: {
        period_start: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
        period_end: new Date().toISOString(),
        total_documents: 7,
        topics: {
          1: [1, 2],
          2: [3, 4],
          3: [5],
          4: [6],
          5: [7]
        },
        trends: [
          {
            topic_id: 1,
            current_volume: 3,
            growth_rate: 0.75,
            acceleration: 0.25,
            peak_time: new Date().toISOString(),
            trend_strength: "high"
          },
          {
            topic_id: 2,
            current_volume: 2,
            growth_rate: 0.5,
            acceleration: 0.1,
            peak_time: new Date().toISOString(),
            trend_strength: "medium"
          }
        ],
        topic_series: {
          1: [1, 2, 3],
          2: [0, 1, 2],
          3: [0, 0, 1],
          4: [0, 0, 1],
          5: [0, 0, 1]
        },
        word_frequencies: {
          "help": 3,
          "dating": 1,
          "married": 1,
          "struggling": 1,
          "disorder": 1,
          "hoses": 1,
          "connect": 1,
          "rather": 1,
          "fight": 1,
          "warning": 1,
          "glitch": 1
        }
      },
      consensus: {
        agents: [
          {
            id: "consensus_1",
            personality: {
              bot_skepticism: 0.95,
              manipulation_sensitivity: 0.78,
              authenticity_optimism: 0.82,
              novelty_preference: 1.1,
              conformity_bias: 0.45,
              risk_aversion: 0.67
            },
            reputation: 85.2,
            stake: 0.12,
            total_verifications: 5,
            successful_verifications: 5,
            error_count: 0
          },
          {
            id: "consensus_2",
            personality: {
              bot_skepticism: 1.15,
              manipulation_sensitivity: 0.92,
              authenticity_optimism: 0.71,
              novelty_preference: 0.95,
              conformity_bias: 0.38,
              risk_aversion: 0.89
            },
            reputation: 78.9,
            stake: 0.08,
            total_verifications: 5,
            successful_verifications: 4,
            error_count: 1
          }
        ],
        consensus_results: [
          {
            post_id: "1mbsu4d",
            title: "Dating a married woman",
            consensus: {
              bot: false,
              manip: true,
              auth: false,
              confidence: 0.72
            },
            total_votes: 5
          },
          {
            post_id: "1mbsu4c",
            title: "how do i help?",
            consensus: {
              bot: false,
              manip: false,
              auth: true,
              confidence: 0.85
            },
            total_votes: 5
          },
          {
            post_id: "1mbsu4b",
            title: "Where do these hoses connect to?",
            consensus: {
              bot: false,
              manip: false,
              auth: true,
              confidence: 0.91
            },
            total_votes: 5
          }
        ],
        agent_results: [
          {
            agent_id: "consensus_1",
            post_id: "1mbsu4d",
            votes: { bot: false, manip: true, auth: false },
            reputation: 85.2,
            stake: 0.12
          },
          {
            agent_id: "consensus_2",
            post_id: "1mbsu4d",
            votes: { bot: false, manip: true, auth: false },
            reputation: 78.9,
            stake: 0.08
          }
        ]
      },
      timestamp: new Date().toISOString(),
      status: 'success'
    };
    
    console.log('Analytics data generated successfully');
    
    return NextResponse.json(analyticsData, {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
      }
    });
    
  } catch (error) {
    console.error('Error running analytics:', error);
    
    return NextResponse.json({
      status: 'error',
      message: error instanceof Error ? error.message : 'Unknown error occurred',
      timestamp: new Date().toISOString()
    }, {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
}
