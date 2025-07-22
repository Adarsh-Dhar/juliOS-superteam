import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

function getStatusFilter(status?: string) {
  if (!status) return {};
  const now = new Date();
  if (status === 'active') {
    return {
      startDate: { lte: now },
      OR: [
        { endDate: null },
        { endDate: { gte: now } },
      ],
    };
  } else if (status === 'completed') {
    return {
      endDate: { lt: now },
    };
  }
  return {};
}

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const status = searchParams.get('status') || undefined;
  const limit = parseInt(searchParams.get('limit') || '10', 10);
  const offset = parseInt(searchParams.get('offset') || '0', 10);

  const where = getStatusFilter(status);

  const [campaigns, total] = await Promise.all([
    prisma.campaign.findMany({
      where,
      skip: offset,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.campaign.count({ where }),
  ]);

  return NextResponse.json({ campaigns, total });
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const { name, hashtag, description } = data;
  if (!name || !hashtag) {
    return NextResponse.json({ error: 'Missing name or hashtag' }, { status: 400 });
  }
  const campaign = await prisma.campaign.create({
    data: {
      name,
      hashtag,
      description,
      startDate: new Date(),
    },
  });
  return NextResponse.json(campaign);
} 