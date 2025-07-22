import { NextRequest, NextResponse } from 'next/server';

const posts = [
  { id: '1', campaignId: '1', content: 'Post 1 for campaign 1' },
  { id: '2', campaignId: '1', content: 'Post 2 for campaign 1' },
  { id: '3', campaignId: '2', content: 'Post 1 for campaign 2' },
];

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const post = posts.find(p => p.id === params.id);
  if (!post) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json(post);
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: params.id });
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  return NextResponse.json({ success: true, id: params.id });
} 