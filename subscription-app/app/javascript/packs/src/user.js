// temp debug
console.log("=== USER JS LOADED")

// would be nice if could get this from server configured ENV['STRIPE_PUBLIC_KEY']
const stripe = Stripe("pk_test_51LedmsF96LECznkNClct0c8ChZ9vdfheGYdBggXLcNlbn53q3GQc6xrSzHAFNMjVIMl5pnxrYzDCowkB9h8pTItW00n358I48H");

// This is used to generate Manage Billing link/form - will skip this for now
// In production, this should check CSRF, and not pass the session ID.
// The customer ID for the portal should be pulled from the
// authenticated user on the server.
// document.addEventListener('DOMContentLoaded', async () => {
//   let searchParams = new URLSearchParams(window.location.search);
//   if (searchParams.has('session_id')) {
//     const session_id = searchParams.get('session_id');
//     document.getElementById('session-id').setAttribute('value', session_id);
//   }
// });
