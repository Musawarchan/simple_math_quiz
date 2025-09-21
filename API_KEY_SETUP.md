# API Key Security Setup

## ⚠️ Important Security Notice

Your Gemini API key has been removed from the codebase for security reasons. Follow these steps to set up your API key securely.

## Setup Instructions

### Option 1: Environment Variables (Recommended)

1. **Create a `.env` file** in the project root:
   ```bash
   # Copy the example file
   cp .env.example .env
   ```

2. **Edit the `.env` file** and add your actual API key:
   ```
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

3. **The `.env` file is already in `.gitignore`** - it won't be committed to version control.

### Option 2: App Settings (Alternative)

You can also set the API key through the app's AI Settings screen:
1. Open the app
2. Go to AI Learning tab
3. Tap the settings icon (⚙️)
4. Enter your API key
5. Tap "Save API Key"

## Getting Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Click "Get API key" and create a new key
4. Copy the generated API key

## Security Features

- ✅ API keys are no longer hardcoded in the source code
- ✅ `.env` files are excluded from version control
- ✅ Environment variables take priority over stored keys
- ✅ Clear error messages when API key is missing
- ✅ API key can be set through app settings as fallback

## File Structure

```
mvp_app/
├── .env                    # Your actual API key (not in git)
├── .env.example           # Template file (safe to commit)
├── .gitignore             # Excludes .env files
└── lib/
    ├── main.dart          # Loads environment variables
    └── services/
        └── ai_learning_service.dart  # Uses secure API key retrieval
```

## Troubleshooting

### "API Key Required" Error
- Make sure you've created a `.env` file with your API key
- Check that the key is correctly formatted (no extra spaces)
- Verify the key is valid at [Google AI Studio](https://aistudio.google.com/)

### App Not Loading
- Ensure the `.env` file exists in the project root
- Check that `flutter_dotenv` dependency is installed
- Run `flutter pub get` to install dependencies

## Next Steps

1. **Immediately revoke the exposed API key** at [Google AI Studio](https://aistudio.google.com/)
2. **Generate a new API key** and add it to your `.env` file
3. **Test the app** to ensure everything works correctly
4. **Commit your changes** (the `.env` file will be ignored by git)
