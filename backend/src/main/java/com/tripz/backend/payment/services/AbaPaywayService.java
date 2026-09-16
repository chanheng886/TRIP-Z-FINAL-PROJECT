package com.tripz.backend.payment.services;

import com.tripz.backend.payment.dto.AbaCallbackDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * AbaPaywayService
 *
 * Handles ABA Payway payment operations:
 *  - Generating a signed checkout URL for the Flutter WebView
 *  - Verifying the RSA-SHA256 callback signature from ABA servers
 */
@Slf4j
@Service
public class AbaPaywayService {

    @Value("${aba.merchant-id}")
    private String merchantId;

    @Value("${aba.private-key}")
    private String privateKeyPem;

    @Value("${aba.public-key}")
    private String publicKeyPem;

    @Value("${aba.payway-url}")
    private String paywayBaseUrl;

    @Value("${aba.return-url}")
    private String returnUrl;

    @Value("${aba.cancel-url}")
    private String cancelUrl;

    @Value("${aba.purchase-url:https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase}")
    private String purchaseUrl;

    @Value("${aba.api-key:}")
    private String apiKey;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
    private final java.net.http.HttpClient httpClient = java.net.http.HttpClient.newBuilder()
            .connectTimeout(java.time.Duration.ofSeconds(15))
            .build();

    /**
     * Directly calls the ABA PayWay /purchase API server-to-server.
     * ABA returns the official KHQR qrString, qrImage, and abapay_deeplink.
     */
    public com.tripz.backend.payment.dto.AbaCheckoutResponseDTO createPurchase(String transactionId, double amount) {
        try {
            String reqTime = java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
                    .withZone(java.time.ZoneOffset.UTC)
                    .format(Instant.now());

            String amountStr = String.format(java.util.Locale.US, "%.2f", amount);

            if (transactionId.length() > 20) {
                transactionId = transactionId.substring(0, 20);
            }

            String itemsJson = "[{\"name\":\"Bus Ticket\",\"quantity\":\"1\",\"price\":\"" + amountStr + "\"}]";
            String items = Base64.getEncoder().encodeToString(itemsJson.getBytes(StandardCharsets.UTF_8));

            String shipping = "0.00";
            String firstname = "";
            String lastname = "";
            String email = "";
            String phone = "";
            String type = "purchase";
            String paymentOption = "";
            String returnUrlB64 = Base64.getEncoder().encodeToString(returnUrl.getBytes(StandardCharsets.UTF_8));
            String cancelUrlVal = cancelUrl;
            String continueSuccessUrl = returnUrl;
            String returnDeeplink = "";
            String currency = "USD";
            String customFields = "";
            String returnParams = transactionId;
            String payout = "";
            String lifetime = "30";
            String additionalParams = "";
            String googlePayToken = "";
            String skipSuccessPage = "";

            String b4hash = reqTime
                    + merchantId
                    + transactionId
                    + amountStr
                    + items
                    + shipping
                    + firstname
                    + lastname
                    + email
                    + phone
                    + type
                    + paymentOption
                    + returnUrlB64
                    + cancelUrlVal
                    + continueSuccessUrl
                    + returnDeeplink
                    + currency
                    + customFields
                    + returnParams
                    + payout
                    + lifetime
                    + additionalParams
                    + googlePayToken
                    + skipSuccessPage;

            if (apiKey == null || apiKey.isBlank()) {
                throw new IllegalStateException("ABA Payway API key (aba.api-key) is not configured.");
            }
            String hash = generateHmacSha512(b4hash, apiKey.trim());

            Map<String, String> formFields = new LinkedHashMap<>();
            formFields.put("req_time", reqTime);
            formFields.put("merchant_id", merchantId);
            formFields.put("tran_id", transactionId);
            formFields.put("amount", amountStr);
            formFields.put("items", items);
            formFields.put("shipping", shipping);
            formFields.put("type", type);
            formFields.put("return_url", returnUrlB64);
            formFields.put("cancel_url", cancelUrlVal);
            formFields.put("continue_success_url", continueSuccessUrl);
            formFields.put("currency", currency);
            formFields.put("return_params", returnParams);
            formFields.put("lifetime", lifetime);
            formFields.put("hash", hash);

            StringBuilder formData = new StringBuilder();
            for (Map.Entry<String, String> entry : formFields.entrySet()) {
                if (formData.length() > 0) formData.append("&");
                formData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8))
                        .append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
            }

            log.info("[AbaPayway] Calling ABA /purchase API for tran_id={}, amount={}", transactionId, amountStr);
            java.net.http.HttpRequest httpRequest = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(purchaseUrl))
                    .timeout(java.time.Duration.ofSeconds(20))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                    .POST(java.net.http.HttpRequest.BodyPublishers.ofString(formData.toString()))
                    .build();

            java.net.http.HttpResponse<String> httpResponse = httpClient.send(
                    httpRequest, java.net.http.HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

            log.info("[AbaPayway] ABA /purchase response status: {}", httpResponse.statusCode());
            String responseBody = httpResponse.body();
            log.debug("[AbaPayway] ABA /purchase body: {}", responseBody);

            com.fasterxml.jackson.databind.JsonNode root = objectMapper.readTree(responseBody);
            String qrString = root.path("qrString").asText(null);
            String qrImage = root.path("qrImage").asText(null);
            String abapayDeeplink = root.path("abapay_deeplink").asText(null);
            String statusCode = root.path("status").path("code").asText("");

            return com.tripz.backend.payment.dto.AbaCheckoutResponseDTO.builder()
                    .transactionId(transactionId)
                    .status("00".equals(statusCode) ? "PENDING" : "FAILED")
                    .qrString(qrString)
                    .qrImage(qrImage)
                    .abapayDeeplink(abapayDeeplink)
                    .checkoutUrl(createCheckoutHtml(transactionId, amount))
                    .build();

        } catch (Exception e) {
            log.error("[AbaPayway] Failed to call ABA /purchase: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to initiate ABA Payway purchase", e);
        }
    }

    /**
     * Checks the transaction status via ABA PayWay /check-transaction-2 API.
     */
    public com.tripz.backend.payment.dto.AbaTransactionStatusDTO checkTransaction(String transactionId) {
        try {
            String reqTime = java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
                    .withZone(java.time.ZoneOffset.UTC)
                    .format(Instant.now());

            String b4hash = reqTime + merchantId + transactionId;
            String hash = generateHmacSha512(b4hash, apiKey.trim());

            String checkUrl = purchaseUrl.replace("/purchase", "/check-transaction-2");

            String body = "req_time=" + URLEncoder.encode(reqTime, StandardCharsets.UTF_8)
                    + "&merchant_id=" + URLEncoder.encode(merchantId, StandardCharsets.UTF_8)
                    + "&tran_id=" + URLEncoder.encode(transactionId, StandardCharsets.UTF_8)
                    + "&hash=" + URLEncoder.encode(hash, StandardCharsets.UTF_8);

            java.net.http.HttpRequest httpRequest = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(checkUrl))
                    .timeout(java.time.Duration.ofSeconds(15))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(java.net.http.HttpRequest.BodyPublishers.ofString(body))
                    .build();

            java.net.http.HttpResponse<String> httpResponse = httpClient.send(
                    httpRequest, java.net.http.HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

            String responseBody = httpResponse.body();
            log.debug("[AbaPayway] /check-transaction-2 body: {}", responseBody);

            com.fasterxml.jackson.databind.JsonNode root = objectMapper.readTree(responseBody);
            com.fasterxml.jackson.databind.JsonNode dataNode = root.path("data");

            int paymentStatusCode = dataNode.path("payment_status_code").asInt(-1);
            String paymentStatus = dataNode.path("payment_status").asText("UNKNOWN");
            boolean isApproved = (paymentStatusCode == 0) || "APPROVED".equalsIgnoreCase(paymentStatus);

            return com.tripz.backend.payment.dto.AbaTransactionStatusDTO.builder()
                    .tranId(transactionId)
                    .isApproved(isApproved)
                    .paymentStatus(paymentStatus)
                    .paymentStatusCode(paymentStatusCode)
                    .message(root.path("status").path("message").asText(""))
                    .build();

        } catch (Exception e) {
            log.error("[AbaPayway] checkTransaction failed for tran_id={}: {}", transactionId, e.getMessage(), e);
            return com.tripz.backend.payment.dto.AbaTransactionStatusDTO.builder()
                    .tranId(transactionId)
                    .isApproved(false)
                    .paymentStatus("ERROR")
                    .message(e.getMessage())
                    .build();
        }
    }

    /**
     * Generates an HTML page containing a self-submitting POST form for ABA Payway Hosted Checkout.
     *
     * Posts directly to the purchase API endpoint:
     * https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase
     *
     * @param transactionId unique transaction ID (max 20 characters per ABA Payway spec)
     * @param amount        payment amount (USD)
     * @return HTML string with a self-submitting form to be loaded in the Flutter WebView
     */
    public String createCheckoutHtml(String transactionId, double amount) {
        try {

            // ---------------------------------------------------------------
            // ABA Payway /purchase field values
            // Reference: https://developer.payway.com.kh/#purchase
            // ---------------------------------------------------------------
            String reqTime = java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss")
                    .withZone(java.time.ZoneOffset.UTC)
                    .format(Instant.now());

            String amountStr = String.format(java.util.Locale.US, "%.2f", amount);

            // tran_id strictly max 20 characters per ABA spec
            if (transactionId.length() > 20) {
                transactionId = transactionId.substring(0, 20);
            }

            // Items: JSON array, Base64-encoded
            String itemsJson = "[{\"name\":\"Bus Ticket\",\"quantity\":\"1\",\"price\":\"" + amountStr + "\"}]";
            String items = Base64.getEncoder().encodeToString(itemsJson.getBytes(StandardCharsets.UTF_8));

            String shipping   = "0.00";
            String firstname  = "";
            String lastname   = "";
            String email      = "";
            String phone      = "";
            String type       = "purchase";
            // Empty payment_option = customer can choose Card, ABA Mobile, or KHQR
            // Setting it to "abapay" would force ABA app and cause Play Store redirect
            String paymentOption = "";
            // return_url must be Base64-encoded per ABA Payway spec
            String returnUrlB64 = Base64.getEncoder().encodeToString(returnUrl.getBytes(StandardCharsets.UTF_8));
            // cancel_url is a plain URL (NOT Base64)
            String cancelUrlVal = cancelUrl;
            // continue_success_url = same as return_url (plain URL, NOT Base64)
            String continueSuccessUrl = returnUrl;
            String returnDeeplink = "";
            String currency     = "USD";
            String customFields = "";
            String returnParams = transactionId;
            String payout       = "";
            String lifetime     = "30";
            String additionalParams = "";
            String googlePayToken = "";
            String skipSuccessPage = "";

            // ---------------------------------------------------------------
            // Hash input — concatenation of values in EXACT ABA-specified order.
            // Fields not used are included as empty strings to preserve positions.
            // ---------------------------------------------------------------
            String b4hash = reqTime
                    + merchantId
                    + transactionId
                    + amountStr
                    + items
                    + shipping
                    + firstname
                    + lastname
                    + email
                    + phone
                    + type
                    + paymentOption
                    + returnUrlB64
                    + cancelUrlVal
                    + continueSuccessUrl
                    + returnDeeplink
                    + currency
                    + customFields
                    + returnParams
                    + payout
                    + lifetime
                    + additionalParams
                    + googlePayToken
                    + skipSuccessPage;

            if (apiKey == null || apiKey.isBlank()) {
                log.error("[AbaPayway] aba.api-key is not configured! Set ABA_API_KEY in .env");
                throw new IllegalStateException(
                    "ABA Payway API key (aba.api-key) is not configured. " +
                    "Set ABA_API_KEY in your .env file with the API key from the ABA Payway merchant dashboard."
                );
            }
            String hash = generateHmacSha512(b4hash, apiKey.trim());

            log.debug("[AbaPayway] b4hash={}", b4hash);
            log.debug("[AbaPayway] hash={}", hash);

            // ---------------------------------------------------------------
            // Build form fields — must exactly match the fields used in hash.
            // Only include non-empty fields (omit empties unless ABA requires them).
            // ---------------------------------------------------------------
            Map<String, String> formFields = new LinkedHashMap<>();
            formFields.put("req_time",             reqTime);
            formFields.put("merchant_id",          merchantId);
            formFields.put("tran_id",              transactionId);
            formFields.put("amount",               amountStr);
            formFields.put("items",                items);
            formFields.put("shipping",             shipping);
            formFields.put("type",                 type);
            formFields.put("return_url",           returnUrlB64);
            formFields.put("cancel_url",           cancelUrlVal);
            formFields.put("continue_success_url", continueSuccessUrl);
            formFields.put("currency",             currency);
            formFields.put("return_params",        returnParams);
            formFields.put("lifetime",             lifetime);
            formFields.put("hash",                 hash);

            // Build hidden <input> fields
            StringBuilder inputs = new StringBuilder();
            for (Map.Entry<String, String> entry : formFields.entrySet()) {
                inputs.append(String.format(
                    "    <input type=\"hidden\" name=\"%s\" value=\"%s\" />\n",
                    escapeHtml(entry.getKey()),
                    escapeHtml(entry.getValue())
                ));
            }

            // Self-submitting HTML page — POSTs with default application/x-www-form-urlencoded
            // DO NOT use enctype="multipart/form-data" — ABA's server won't parse it correctly
            // and will fall back to redirecting mobile users to the ABA app / Play Store.
            String html = """
                <!DOCTYPE html>
                <html>
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Connecting to ABA Payway...</title>
                  <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                           display: flex; flex-direction: column; align-items: center; justify-content: center;
                           min-height: 100vh; margin: 0; background: #0b1120; color: #f8fafc; }
                    .card { background: #1e293b; border-radius: 16px; padding: 32px 24px; text-align: center;
                            box-shadow: 0 10px 25px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.1);
                            max-width: 320px; width: 85%; }
                    .spinner { width: 44px; height: 44px; border: 4px solid rgba(255,255,255,0.1);
                               border-top-color: #005A9C; border-radius: 50%;
                               animation: spin 0.8s linear infinite; margin: 0 auto 20px; }
                    @keyframes spin { to { transform: rotate(360deg); } }
                    h3 { font-size: 17px; font-weight: 700; margin: 0 0 8px; color: #ffffff; }
                    p { font-size: 13px; color: #94a3b8; margin: 0; }
                  </style>
                </head>
                <body>
                  <div class="card">
                    <div class="spinner"></div>
                    <h3>Connecting to ABA Payway</h3>
                    <p>Securing your checkout session...</p>
                  </div>
                  <form id="payForm" method="POST" action="%s">
                %s  </form>
                  <script>
                    window.onload = function() {
                      document.getElementById('payForm').submit();
                    };
                  </script>
                </body>
                </html>
                """.formatted(purchaseUrl, inputs.toString());

            log.info("[AbaPayway] Checkout HTML generated for tran_id={}, endpoint={}", transactionId, purchaseUrl);
            return html;

        } catch (Exception e) {
            log.error("[AbaPayway] Failed to create checkout HTML: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate ABA Payway checkout form", e);
        }
    }

    /** Escapes HTML special characters to safely embed values in HTML attributes. */
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");
    }


    /**
     * Verifies the HMAC-SHA512 hash in the ABA Payway callback.
     *
     * ABA Payway sends an HMAC-SHA512 hash in callbacks (NOT RSA).
     * The hash is computed over: merchant_id + tran_id + amount + payment_status
     * using the Merchant API Key as the HMAC secret.
     *
     * @param callback the callback DTO received from ABA Payway servers
     * @return true if the computed HMAC matches the hash in the callback
     */
    public boolean verifyCallbackSignature(AbaCallbackDTO callback) {
        try {
            if (apiKey == null || apiKey.isBlank()) {
                log.warn("[AbaPayway] aba.api-key not configured — skipping callback verification (INSECURE)");
                return true; // allow through but log the warning
            }

            // ABA callback hash input = concatenation of these field VALUES (no keys, no separators)
            String hashInput = nvl(callback.getMerchantId())
                    + nvl(callback.getTranId())
                    + nvl(callback.getAmount())
                    + nvl(callback.getPaymentStatus());

            String expectedHash = generateHmacSha512(hashInput, apiKey.trim());
            boolean valid = expectedHash.equals(callback.getHash());

            if (!valid) {
                log.warn("[AbaPayway] Callback HMAC mismatch. expected={}, received={}",
                        expectedHash, callback.getHash());
            }
            return valid;

        } catch (Exception e) {
            log.error("[AbaPayway] Callback signature verification failed: {}", e.getMessage(), e);
            return false;
        }
    }

    /** Null-safe empty string helper. */
    private String nvl(String value) {
        return value == null ? "" : value;
    }

    // -- Private helpers ----------------------------------------------------

    /** Concatenates param values (not keys) as the hash input string. */
    private String buildHashInput(Map<String, String> params) {
        return String.join("", params.values());
    }

    /** Generates Base64-encoded HMAC-SHA512 hash as required by ABA Payway spec. */
    private String generateHmacSha512(String data, String key) throws Exception {
        javax.crypto.Mac hmac = javax.crypto.Mac.getInstance("HmacSHA512");
        javax.crypto.spec.SecretKeySpec secretKey = new javax.crypto.spec.SecretKeySpec(
                key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
        hmac.init(secretKey);
        byte[] rawHash = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(rawHash);
    }

    /** Signs a string with RSA-SHA256 using the merchant private key. */
    private String signRSA(String data) throws Exception {
        byte[] keyBytes = Base64.getDecoder().decode(stripPemHeaders(privateKeyPem));
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);
        PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(keySpec);

        Signature signer = Signature.getInstance("SHA256withRSA");
        signer.initSign(privateKey);
        signer.update(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(signer.sign());
    }

    /** Verifies a Base64-encoded RSA-SHA256 signature against the ABA public key. */
    private boolean verifyRSA(String data, String signatureBase64) throws Exception {
        byte[] keyBytes = Base64.getDecoder().decode(stripPemHeaders(publicKeyPem));
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
        PublicKey publicKey = KeyFactory.getInstance("RSA").generatePublic(keySpec);

        Signature verifier = Signature.getInstance("SHA256withRSA");
        verifier.initVerify(publicKey);
        verifier.update(data.getBytes(StandardCharsets.UTF_8));
        return verifier.verify(Base64.getDecoder().decode(signatureBase64));
    }

    /** Strips PEM header/footer lines and whitespace. */
    private String stripPemHeaders(String pem) {
        return pem.replace("-----BEGIN PRIVATE KEY-----", "")
                  .replace("-----END PRIVATE KEY-----", "")
                  .replace("-----BEGIN PUBLIC KEY-----", "")
                  .replace("-----END PUBLIC KEY-----", "")
                  .replaceAll("\\s+", "");
    }

    private String urlEncode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
