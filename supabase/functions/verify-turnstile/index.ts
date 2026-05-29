import "@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

export default {
  fetch: async (req: Request) => {
    // Handle CORS preflight request
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }

    try {
      const { token } = await req.json();

      if (!token) {
        return Response.json(
          { error: "Token is required" },
          { status: 400, headers: corsHeaders },
        );
      }

      const secretKey = Deno.env.get("TURNSTILE_SECRET_KEY");
      if (!secretKey) {
        console.error("Missing TURNSTILE_SECRET_KEY in environment variables");
        return Response.json(
          { error: "Server configuration error" },
          { status: 500, headers: corsHeaders },
        );
      }

      // Verify token with Cloudflare
      const params = new URLSearchParams();
      params.append("secret", secretKey);
      params.append("response", token);

      const result = await fetch(
        "https://challenges.cloudflare.com/turnstile/v0/siteverify",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: params.toString(),
        },
      );

      const outcome = await result.json();
      console.log("Cloudflare Turnstile verification outcome:", outcome);

      if (outcome.success) {
        return Response.json(
          { success: true },
          { headers: corsHeaders },
        );
      } else {
        return Response.json(
          {
            success: false,
            error: "Captcha verification failed",
            details: outcome["error-codes"],
          },
          { status: 400, headers: corsHeaders },
        );
      }
    } catch (error) {
      console.error("Error verifying turnstile token:", error);
      return Response.json(
        { error: "Internal Server Error" },
        { status: 500, headers: corsHeaders },
      );
    }
  },
};
