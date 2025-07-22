import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

function sanitizeTitle(content: string | null | undefined): string {
  if (!content) return 'Untitled';
  return content.replace(/[^\w\s]/gi, '').substring(0, 50) + '...';
}

export async function GET() {
  try {
    const certificates = await prisma.certificate.findMany({
      include: {
        verification: {
          include: {
            post: {
              include: {
                socialProfile: true,
              },
            },
            votes: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });

    const formatted = certificates.map(cert => {
      const post = cert.verification?.post;
      const socialProfile = post?.socialProfile;
      const votes = cert.verification?.votes || [];
      return {
        id: cert.id,
        title: sanitizeTitle(post?.content),
        platform: post?.platform || '',
        trustScore: Math.floor(cert.trustScore),
        verifiedAt: cert.createdAt.toISOString(),
        imageUrl: post?.mediaUrl || '',
        description: socialProfile ? `Verified content by ${socialProfile.handle}` : 'Verified content',
        metadata: {
          tokenId: cert.tokenId,
          blockchain: cert.contractAddress.startsWith('0x') ? 'Ethereum' : 'Solana',
          ipfsHash: cert.metadataUri.replace('ipfs://', ''),
          validators: votes.length,
        },
      };
    });

    return NextResponse.json({ certificates: formatted });
  } catch (error) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: String(Date.now()) });
} 