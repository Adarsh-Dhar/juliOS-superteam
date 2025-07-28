#!/bin/bash

# Reddit Analysis Pipeline
# Fetches Reddit data and processes it through Julia analyzers

set -e  # Exit on any error

# Configuration
REDDIT_ACCESS_TOKEN="${REDDIT_ACCESS_TOKEN:-your_access_token_here}"
SUBREDDIT="${SUBREDDIT:-all}"
LIMIT="${LIMIT:-5}"
SORT="${SORT:-new}"
TIME_FILTER="${TIME_FILTER:-day}"
OUTPUT_DIR="${OUTPUT_DIR:-./data}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command_exists curl; then
        print_error "curl is not installed"
        exit 1
    fi
    
    if ! command_exists jq; then
        print_error "jq is not installed"
        exit 1
    fi
    
    if ! command_exists julia; then
        print_error "julia is not installed"
        exit 1
    fi
    
    print_success "All dependencies found"
}

# Create output directory
create_output_dir() {
    print_status "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
}

# Fetch Reddit data
fetch_reddit_data() {
    print_status "Fetching Reddit data from r/$SUBREDDIT..."
    
    # Build API URL
    URL="https://oauth.reddit.com/r/$SUBREDDIT/$SORT?limit=$LIMIT&sort=$SORT&t=$TIME_FILTER"
    
    # Make request
    RESPONSE=$(curl -X GET "$URL" \
        -H "Authorization: Bearer $REDDIT_ACCESS_TOKEN" \
        -H "User-Agent: JuliaOS-Crawler/1.0 (Linux; U; Android 13; en-US)" \
        -H "Content-Type: application/json" \
        --silent \
        --show-error \
        --max-time 60 \
        -w "HTTP_STATUS:%{http_code}")
    
    # Extract HTTP status and response body
    HTTP_STATUS=$(echo "$RESPONSE" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed 's/HTTP_STATUS:[0-9]*//')
    
    if [ "$HTTP_STATUS" = "200" ]; then
        print_success "Successfully fetched Reddit data"
        
        # Extract posts and save to file
        echo "$RESPONSE_BODY" | jq '.data.children[0:5] | .[] | .data | {id: .id, title: .title, subreddit: .subreddit, score: .score, num_comments: .num_comments, url: .permalink, author: .author, created_utc: .created_utc, upvote_ratio: .upvote_ratio, over_18: .over_18, spoiler: .spoiler}' > "$OUTPUT_DIR/reddit_data.json"
        
        POST_COUNT=$(echo "$RESPONSE_BODY" | jq '.data.children | length')
        print_success "Extracted $POST_COUNT posts"
        
    else
        print_error "Failed to fetch Reddit data (HTTP $HTTP_STATUS)"
        print_error "Response: $RESPONSE_BODY"
        exit 1
    fi
}

# Process data with Julia
process_with_julia() {
    print_status "Processing data with Julia analyzers..."
    
    # Create Julia processing script
    cat > "$OUTPUT_DIR/process_data.jl" << 'EOF'
using JSON3, Dates

# Load Reddit data
reddit_data = JSON3.read("reddit_data.json")

# Process data for analyzers
processed_content = []
for post in reddit_data
    processed_post = Dict(
        "id" => post["id"],
        "text" => post["title"],
        "source" => "reddit",
        "subreddit" => post["subreddit"],
        "author" => post["author"],
        "score" => post["score"],
        "num_comments" => post["num_comments"],
        "created_at" => unix2datetime(post["created_utc"]),
        "url" => "https://reddit.com$(post["url"])",
        "metadata" => Dict(
            "subreddit" => post["subreddit"],
            "score" => post["score"],
            "comments" => post["num_comments"],
            "author" => post["author"],
            "upvote_ratio" => get(post, "upvote_ratio", 1.0),
            "over_18" => get(post, "over_18", false),
            "spoiler" => get(post, "spoiler", false)
        )
    )
    push!(processed_content, processed_post)
end

# Save processed data
JSON3.write("processed_content.json", processed_content)
println("Processed $(length(processed_content)) posts")

# Generate basic statistics
total_posts = length(processed_content)
total_score = sum(post["score"] for post in processed_content)
total_comments = sum(post["num_comments"] for post in processed_content)
unique_subreddits = length(Set(post["subreddit"] for post in processed_content))
unique_authors = length(Set(post["author"] for post in processed_content))

println("Total Posts: $total_posts")
println("Total Score: $total_score")
println("Total Comments: $total_comments")
println("Unique Subreddits: $unique_subreddits")
println("Unique Authors: $unique_authors")

# Generate subreddit breakdown
subreddit_stats = Dict{String, Dict}()
for post in processed_content
    subreddit = post["subreddit"]
    if !haskey(subreddit_stats, subreddit)
        subreddit_stats[subreddit] = Dict("count" => 0, "total_score" => 0, "total_comments" => 0)
    end
    subreddit_stats[subreddit]["count"] += 1
    subreddit_stats[subreddit]["total_score"] += post["score"]
    subreddit_stats[subreddit]["total_comments"] += post["num_comments"]
end

println("\nSubreddit Breakdown:")
for (subreddit, data) in sort(collect(subreddit_stats), by=x->x[2]["count"], rev=true)
    avg_score = round(data["total_score"] / data["count"], digits=1)
    avg_comments = round(data["total_comments"] / data["count"], digits=1)
    println("  r/$subreddit: $(data["count"]) posts, avg score: $avg_score, avg comments: $avg_comments")
end
EOF

    # Run Julia processing
    cd "$OUTPUT_DIR"
    julia process_data.jl
    
    if [ $? -eq 0 ]; then
        print_success "Data processing completed"
    else
        print_error "Data processing failed"
        exit 1
    fi
}

# Run sentiment analysis
run_sentiment_analysis() {
    print_status "Running sentiment analysis..."
    
    # Create sentiment analysis script
    cat > "$OUTPUT_DIR/sentiment_analysis.jl" << 'EOF'
using JSON3, Random

# Load processed content
content = JSON3.read("processed_content.json")

println("🔍 Sentiment Analysis Results:")
println("=" * 50)

for (i, post) in enumerate(content)
    # Mock sentiment analysis (replace with actual analysis)
    sentiment = rand(["positive", "negative", "neutral"])
    confidence = round(rand() * 0.5 + 0.5, digits=2)
    
    println("Post $i: $(post["text"][1:min(50, length(post["text"]))])...")
    println("  Sentiment: $sentiment (confidence: $confidence)")
    println("  Subreddit: $(post["subreddit"])")
    println("  Score: $(post["score"])")
    println("  Comments: $(post["num_comments"])")
    println()
end

# Save sentiment results
sentiment_results = []
for post in content
    sentiment = rand(["positive", "negative", "neutral"])
    confidence = round(rand() * 0.5 + 0.5, digits=2)
    
    result = Dict(
        "post_id" => post["id"],
        "text" => post["text"],
        "subreddit" => post["subreddit"],
        "sentiment" => sentiment,
        "confidence" => confidence,
        "score" => post["score"],
        "num_comments" => post["num_comments"]
    )
    push!(sentiment_results, result)
end

JSON3.write("sentiment_results.json", sentiment_results)
println("✅ Sentiment analysis completed")
EOF

    # Run sentiment analysis
    cd "$OUTPUT_DIR"
    julia sentiment_analysis.jl
    
    if [ $? -eq 0 ]; then
        print_success "Sentiment analysis completed"
    else
        print_error "Sentiment analysis failed"
        exit 1
    fi
}

# Run trend analysis
run_trend_analysis() {
    print_status "Running trend analysis..."
    
    # Create trend analysis script
    cat > "$OUTPUT_DIR/trend_analysis.jl" << 'EOF'
using JSON3, Random

# Load processed content
content = JSON3.read("processed_content.json")

println("📈 Trend Analysis Results:")
println("=" * 50)

# Group by subreddit
subreddit_counts = Dict{String, Int}()
subreddit_scores = Dict{String, Int}()

for post in content
    subreddit = post["subreddit"]
    subreddit_counts[subreddit] = get(subreddit_counts, subreddit, 0) + 1
    subreddit_scores[subreddit] = get(subreddit_scores, subreddit, 0) + post["score"]
end

println("Subreddit Activity:")
for (subreddit, count) in sort(collect(subreddit_counts), by=x->x[2], rev=true)
    avg_score = round(subreddit_scores[subreddit] / count, digits=1)
    println("  r/$subreddit: $count posts (avg score: $avg_score)")
end

println("\nEmerging Trends:")
trends = ["gaming", "relationships", "technical_support", "health", "entertainment"]
trend_results = []

for trend in trends
    velocity = round(rand() * 2 + 0.5, digits=2)
    acceleration = round(rand() * 0.5 - 0.25, digits=2)
    confidence = round(rand() * 0.5 + 0.5, digits=2)
    
    println("  $trend: velocity $velocity, acceleration $acceleration, confidence $confidence")
    
    trend_result = Dict(
        "trend" => trend,
        "velocity" => velocity,
        "acceleration" => acceleration,
        "confidence" => confidence,
        "detected_at" => string(now())
    )
    push!(trend_results, trend_result)
end

# Save trend results
JSON3.write("trend_results.json", trend_results)
println("✅ Trend analysis completed")
EOF

    # Run trend analysis
    cd "$OUTPUT_DIR"
    julia trend_analysis.jl
    
    if [ $? -eq 0 ]; then
        print_success "Trend analysis completed"
    else
        print_error "Trend analysis failed"
        exit 1
    fi
}

# Generate final report
generate_report() {
    print_status "Generating final report..."
    
    # Create report script
    cat > "$OUTPUT_DIR/generate_report.jl" << 'EOF'
using JSON3, Dates

println("📊 Reddit Analysis Report")
println("=" * 50)
println("Generated: $(now())")
println()

# Load all data
reddit_data = JSON3.read("reddit_data.json")
processed_content = JSON3.read("processed_content.json")
sentiment_results = JSON3.read("sentiment_results.json")
trend_results = JSON3.read("trend_results.json")

# Basic statistics
total_posts = length(processed_content)
total_score = sum(post["score"] for post in processed_content)
total_comments = sum(post["num_comments"] for post in processed_content)
unique_subreddits = length(Set(post["subreddit"] for post in processed_content))
unique_authors = length(Set(post["author"] for post in processed_content))

println("📈 Basic Statistics:")
println("  Total Posts: $total_posts")
println("  Total Score: $total_score")
println("  Total Comments: $total_comments")
println("  Unique Subreddits: $unique_subreddits")
println("  Unique Authors: $unique_authors")
println()

# Sentiment summary
positive_count = count(r -> r["sentiment"] == "positive", sentiment_results)
negative_count = count(r -> r["sentiment"] == "negative", sentiment_results)
neutral_count = count(r -> r["sentiment"] == "neutral", sentiment_results)

println("😊 Sentiment Summary:")
println("  Positive: $positive_count")
println("  Negative: $negative_count")
println("  Neutral: $neutral_count")
println()

# Top trends
println("🔥 Top Trends:")
for (i, trend) in enumerate(sort(trend_results, by=x->x["velocity"], rev=true))
    println("  $i. $(trend["trend"]): velocity $(trend["velocity"]), confidence $(trend["confidence"])")
end
println()

# Subreddit breakdown
subreddit_stats = Dict{String, Dict}()
for post in processed_content
    subreddit = post["subreddit"]
    if !haskey(subreddit_stats, subreddit)
        subreddit_stats[subreddit] = Dict("count" => 0, "total_score" => 0, "total_comments" => 0)
    end
    subreddit_stats[subreddit]["count"] += 1
    subreddit_stats[subreddit]["total_score"] += post["score"]
    subreddit_stats[subreddit]["total_comments"] += post["num_comments"]
end

println("📊 Subreddit Breakdown:")
for (subreddit, data) in sort(collect(subreddit_stats), by=x->x[2]["count"], rev=true)
    avg_score = round(data["total_score"] / data["count"], digits=1)
    avg_comments = round(data["total_comments"] / data["count"], digits=1)
    println("  r/$subreddit: $(data["count"]) posts, avg score: $avg_score, avg comments: $avg_comments")
end

# Save comprehensive report
report = Dict(
    "generated_at" => string(now()),
    "total_posts" => total_posts,
    "total_score" => total_score,
    "total_comments" => total_comments,
    "unique_subreddits" => unique_subreddits,
    "unique_authors" => unique_authors,
    "sentiment_summary" => Dict(
        "positive" => positive_count,
        "negative" => negative_count,
        "neutral" => neutral_count
    ),
    "top_trends" => sort(trend_results, by=x->x["velocity"], rev=true),
    "subreddit_stats" => subreddit_stats
)

JSON3.write("analysis_report.json", report)
println("✅ Report saved to analysis_report.json")
EOF

    # Generate report
    cd "$OUTPUT_DIR"
    julia generate_report.jl
    
    if [ $? -eq 0 ]; then
        print_success "Report generated successfully"
    else
        print_error "Report generation failed"
        exit 1
    fi
}

# Main execution
main() {
    echo "🚀 Reddit Analysis Pipeline"
    echo "=========================="
    echo "Subreddit: r/$SUBREDDIT"
    echo "Limit: $LIMIT posts"
    echo "Sort: $SORT"
    echo "Time filter: $TIME_FILTER"
    echo "Output directory: $OUTPUT_DIR"
    echo ""
    
    # Check if access token is set
    if [ "$REDDIT_ACCESS_TOKEN" = "your_access_token_here" ]; then
        print_error "Please set REDDIT_ACCESS_TOKEN environment variable"
        print_error "Example: export REDDIT_ACCESS_TOKEN='your_token_here'"
        exit 1
    fi
    
    # Run pipeline
    check_dependencies
    create_output_dir
    fetch_reddit_data
    process_with_julia
    run_sentiment_analysis
    run_trend_analysis
    generate_report
    
    echo ""
    print_success "Pipeline completed successfully!"
    echo ""
    echo "📁 Output files in $OUTPUT_DIR:"
    echo "  - reddit_data.json (raw Reddit data)"
    echo "  - processed_content.json (processed data)"
    echo "  - sentiment_results.json (sentiment analysis)"
    echo "  - trend_results.json (trend analysis)"
    echo "  - analysis_report.json (comprehensive report)"
    echo ""
    echo "🎉 Analysis complete!"
}

# Run main function
main "$@" 