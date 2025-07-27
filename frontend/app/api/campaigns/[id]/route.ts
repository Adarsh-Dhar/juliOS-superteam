import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const campaign = await prisma.campaign.findUnique({
    where: { id: params.id },
  });
  if (!campaign) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json({ ...campaign, trustScore: campaign.trustScore });
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  // For demo, just echo back
  const data = await req.json();
  return NextResponse.json({ ...data, id: params.id });
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  // For demo, just return success
  return NextResponse.json({ success: true, id: params.id });
} 