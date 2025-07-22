import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { VerificationStatus } from '@prisma/client';

function getStatusFilter(status?: string) {
  if (!status) return {};
  if (status === 'pending') return { verification: { is: { status: VerificationStatus.PENDING } } };
  if (status === 'authentic') return { verification: { is: { status: VerificationStatus.AUTHENTIC } } };
  if (status === 'fake') return { verification: { is: { status: VerificationStatus.FAKE } } };
  return {};
}

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const { searchParams } = new URL(req.url);
  const status = searchParams.get('status') || undefined;
  const limit = parseInt(searchParams.get('limit') || '10', 10);
  const offset = parseInt(searchParams.get('offset') || '0', 10);

  const where = {
    campaignId: params.id,
    ...getStatusFilter(status),
  };

  const [posts, total] = await Promise.all([
    prisma.post.findMany({
      where,
      skip: offset,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.post.count({ where }),
  ]);

  return NextResponse.json({ posts, total });
}

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  // For demo, just echo back with a fake id
  return NextResponse.json({ ...data, id: String(Date.now()), campaignId: params.id });
} 