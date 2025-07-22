import { NextResponse } from 'next/server';

export async function GET() {
  // Mock analytics data
  return NextResponse.json({
    totalCampaigns: 2,
    totalPosts: 3,
    engagement: 87,
  });
} 