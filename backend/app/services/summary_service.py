# LLM call using featherless.ai to summarize transcription
from openai import OpenAI

from app.config import FEATHERLESS_API_KEY

client = OpenAI(
    base_url="https://api.featherless.ai/v1",
    api_key=FEATHERLESS_API_KEY,
)


def summarize_transcript(transcript: str) -> str:
    """Takes a transcript string and returns an LLM-generated summary."""
    response = client.chat.completions.create(
        model="meta-llama/Meta-Llama-3.1-8B-Instruct",
        messages=[
            {
                "role": "user",
                "content": f"Summarize the following transcript:\n\n{transcript}"
            }
        ],
    )
    return response.choices[0].message.content