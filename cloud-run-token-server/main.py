"""Monti Cloud Run Backend — Token server + AI character image generation.

Endpoints:
  GET  /token              — Fresh Vertex AI access token
  POST /generate-character — Generate a flat emoji-style character image
  GET  /health             — Health check
"""

import base64
import os

from flask import Flask, jsonify, request
import google.auth
import google.auth.transport.requests
from google import genai
from google.genai import types

app = Flask(__name__)

ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*")
LOCATION = os.environ.get("LOCATION", "us-central1")


def _get_credentials():
    credentials, project = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    auth_request = google.auth.transport.requests.Request()
    credentials.refresh(auth_request)
    return credentials, project


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = ALLOWED_ORIGINS
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, X-API-Key"
    return response


@app.route("/token", methods=["GET"])
def get_token():
    """Return a fresh access token for Vertex AI."""
    try:
        credentials, project = _get_credentials()
        return jsonify({
            "access_token": credentials.token,
            "project_id": project,
            "expires_in": 3600,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/generate-character", methods=["POST", "OPTIONS"])
def generate_character():
    """Generate a flat emoji-style character image using Gemini 3.1 Flash.

    Request body: { "prompt": "a friendly purple dinosaur" }
    Response: { "image": "<base64 png data>" }
    """
    if request.method == "OPTIONS":
        return "", 204

    data = request.get_json(silent=True) or {}
    user_prompt = data.get("prompt", "").strip()
    if not user_prompt:
        return jsonify({"error": "prompt is required"}), 400

    try:
        # Use Google AI endpoint for image generation model
        api_key = os.environ.get("GEMINI_API_KEY", "")
        if not api_key:
            return jsonify({"error": "GEMINI_API_KEY not configured"}), 500

        client = genai.Client(api_key=api_key)

        full_prompt = (
            f"Generate an image of: a cute {user_prompt} character. "
            "STRICT STYLE RULES: "
            "- Flat vector illustration, 2D, no 3D, no shadows, no gradients "
            "- Solid warm off-white background (#FFFBF5), no patterns, no scenery "
            "- Single character only, centered, facing forward "
            "- Chibi/kawaii proportions: big round head, small body, big eyes "
            "- Soft rounded shapes, thick outlines "
            "- Warm pastel color palette (orange, peach, mint, sky blue) "
            "- Friendly happy expression, simple smile "
            "- No text, no words, no watermarks "
            "- Children's app icon style, like Apple emoji but cuter"
        )

        config = types.GenerateContentConfig(
            response_modalities=["IMAGE", "TEXT"],
        )

        response = client.models.generate_content(
            model="gemini-3.1-flash-image-preview",
            contents=full_prompt,
            config=config,
        )

        # Extract image from response
        if response.candidates:
            for candidate in response.candidates:
                if candidate.content and candidate.content.parts:
                    for part in candidate.content.parts:
                        if part.inline_data and part.inline_data.data:
                            image_b64 = base64.b64encode(
                                part.inline_data.data
                            ).decode()
                            return jsonify({"image": image_b64})

        return jsonify({"error": "No image generated"}), 502

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "monti-backend"})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
