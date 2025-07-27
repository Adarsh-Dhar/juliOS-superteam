import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(req: NextRequest) {
  try {
    // Test database connection
    const result = await prisma.$queryRaw`SELECT 1 as test`;
    console.log('Database connection test result:', result);
    
    return NextResponse.json({ 
      status: 'success', 
      message: 'Database connection working',
      result 
    });
  } catch (error) {
    console.error('Database connection test failed:', error);
    return NextResponse.json({ 
      status: 'error', 
      message: 'Database connection failed',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
} 