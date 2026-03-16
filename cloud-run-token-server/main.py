"""Monti Token Server — Cloud Run service that provides fresh Vertex AI access tokens.

The Flutter app calls this endpoint on session start to get a short-lived
access token for the Gemini Live API, eliminating the need to embed tokens
in the APK.
"""

import os
import json

from flask import Flask, jsonify, request
import google.auth
import google.auth.transport.requests

app = Flask(__name__)

# Allow configuring allowed origins for CORS
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*")


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = ALLOWED_ORIGINS
    response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, X-API-Key"
    return response


@app.route("/token", methods=["GET"])
def get_token():
    """Return a fresh access token for Vertex AI.

    The service account running this Cloud Run service must have
    the 'Vertex AI User' role (roles/aiplatform.user).
    """
    # Validate API key if configured
    expected_key = os.environ.get("API_KEY")
    if expected_key:
        provided_key = request.headers.get("X-API-Key", "")
        if provided_key != expected_key:
            return jsonify({"error": "Unauthorized"}), 401

    try:
        credentials, project = google.auth.default(
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )
        auth_request = google.auth.transport.requests.Request()
        credentials.refresh(auth_request)

        return jsonify({
            "access_token": credentials.token,
            "project_id": project,
            "expires_in": 3600,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "monti-token-server"})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
