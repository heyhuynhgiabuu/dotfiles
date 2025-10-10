import { tool } from "@opencode-ai/plugin";

export default tool({
  description:
    "Run a search query to search the internet for results. Use this to look up latest information or find documentation.",
  args: {
    query: tool.schema.string().describe("search query"),
  },
  execute: async (args) => {
    if (!process.env.PERPLEXITY_API_KEY) {
      throw new Error("PERPLEXITY_API_KEY environment variable not configured");
    }

    const sanitizedQuery = args.query.replace(/['"\\]/g, "");

    const url = "https://api.perplexity.ai/search";

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${process.env.PERPLEXITY_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ query: sanitizedQuery }),
      });

      if (!response.ok) {
        throw new Error(
          `Search API failed: ${response.status} ${response.statusText}`,
        );
      }

      const result = await response.text();

      if (!result || result.trim() === "") {
        return `No results found for query: "${sanitizedQuery}"`;
      }

      return result;
    } catch (error) {
      if (error instanceof Error) {
        return `Search error: ${error.message}`;
      }
      return `Unknown search error occurred`;
    }
  },
});
