import { NextRequest, NextResponse } from 'next/server';

const posts = [
  { id: '1', campaignId: '1', content: 'Post 1 for campaign 1' },
  { id: '2', campaignId: '1', content: 'Post 2 for campaign 1' },
  { id: '3', campaignId: '2', content: 'Post 1 for campaign 2' },
];

export async function GET() {
  return NextResponse.json(posts);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: String(Date.now()) });
} 