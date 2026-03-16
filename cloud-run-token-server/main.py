"""Monti Cloud Run Backend — Token server + AI character image generation.

Endpoints:
  GET  /token              — Fresh Vertex AI access token
  POST /generate-character — Generate a flat emoji-style character image
  GET  /health             — Health check
"""

import base64
import logging
import os

from flask import Flask, jsonify, request
import google.auth
import google.auth.transport.requests
from google import genai
from google.genai import types

app = Flask(__name__)

# Security: API key required for all authenticated endpoints
APP_API_KEY = os.environ.get("APP_API_KEY", "")
LOCATION = os.environ.get("LOCATION", "us-central1")

logger = logging.getLogger(__name__)


def _check_api_key():
    """Validate X-API-Key header. Returns error response or None if valid."""
    if not APP_API_KEY:
        return None  # No key configured = skip check (dev mode)
    provided = request.headers.get("X-API-Key", "")
    if provided != APP_API_KEY:
        return jsonify({"error": "Unauthorized"}), 401
    return None


def _get_credentials():
    credentials, project = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    auth_request = google.auth.transport.requests.Request()
    credentials.refresh(auth_request)
    return credentials, project


@app.after_request
def add_cors_headers(response):
    # Security: No CORS needed for mobile app. Deny browser access.
    response.headers["Access-Control-Allow-Origin"] = ""
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, X-API-Key"
    return response


@app.route("/token", methods=["GET"])
def get_token():
    """Return a fresh access token for Vertex AI."""
    auth_error = _check_api_key()
    if auth_error:
        return auth_error

    try:
        credentials, project = _get_credentials()
        return jsonify({
            "access_token": credentials.token,
            "project_id": project,
            "expires_in": 3600,
        })
    except Exception as e:
        logger.exception("Token generation failed")
        return jsonify({"error": "Failed to generate token"}), 500


@app.route("/generate-character", methods=["POST", "OPTIONS"])
def generate_character():
    """Generate a flat emoji-style character image using Gemini 3.1 Flash."""
    if request.method == "OPTIONS":
        return "", 204

    auth_error = _check_api_key()
    if auth_error:
        return auth_error

    data = request.get_json(silent=True) or {}
    user_prompt = data.get("prompt", "").strip()
    if not user_prompt:
        return jsonify({"error": "prompt is required"}), 400

    # Input length validation
    if len(user_prompt) > 500:
        return jsonify({"error": "prompt too long (max 500 chars)"}), 400

    try:
        api_key = os.environ.get("GEMINI_API_KEY", "")
        if not api_key:
            return jsonify({"error": "Image generation not configured"}), 500

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
        logger.exception("Character generation failed")
        return jsonify({"error": "Image generation failed"}), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "monti-backend"})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
