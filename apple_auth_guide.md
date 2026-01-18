# Getting an App Store Connect API Key

To automate iOS builds and uploads (e.g., using GitHub Actions or Fastlane), you need an App Store Connect API Key.

## Step 1: Generate the Key
1.  Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2.  Go to **Users and Access**.
3.  Click the **Integrations** tab (top menu).
4.  Select **Team Keys** (sidebar).
5.  Click the **+ (plus)** button to generate a new key.
    *   **Name:** `GitHub Actions` (or similar).
    *   **Access:** `App Manager` (required for uploading builds) or `Admin`.
6.  Click **Generate**.

## Step 2: Download & Save
1.  Once generated, you will see a **Download API Key** link.
2.  **CLICK CAREFULLY:** You can only download this file **ONCE**.
3.  Save the `.p8` file (e.g., `AuthKey_XXXXXXXXXX.p8`) to a secure location.
4.  Note the following values from the page:
    *   **Issuer ID:** A UUID (e.g., `572435b8-37a5-4301-8586-5d92dd849802`).
    *   **Key ID:** A 10-character string (e.g., `D383SF739`).

## Step 3: Add to GitHub Secrets
If you plan to use this for the deployment workflow, add these as secrets in your GitHub Repo:
*   `APP_STORE_CONNECT_API_KEY_BASE64`: The content of the `.p8` file (base64 encoded).
    *   Run `base64 -i AuthKey_XXXXXXXXXX.p8` in your terminal to get this string.
*   `APP_STORE_CONNECT_ISSUER_ID`: The Issuer ID.
*   `APP_STORE_CONNECT_KEY_ID`: The Key ID.
