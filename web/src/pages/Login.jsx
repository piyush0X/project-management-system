import {
  useState,
} from "react";

import {
  Link,
  useNavigate,
  useSearchParams,
} from "react-router-dom";

import { useAuth } from "../context/AuthContext";


export default function Login() {

  const {
    login,
  } = useAuth();

  const navigate =
    useNavigate();

  const [
    searchParams,
  ] = useSearchParams();


  const [
    email,
    setEmail,
  ] = useState("");


  const [
    password,
    setPassword,
  ] = useState("");


  const [
    error,
    setError,
  ] = useState("");


  const [
    loading,
    setLoading,
  ] = useState(false);


  const tokenExpired =
    searchParams.get("reason")
    === "expired";


  async function handleSubmit(event) {

    event.preventDefault();

    setError("");


    if (!email || !password) {

      setError(
        "Email and password are required."
      );

      return;
    }


    try {

      setLoading(true);

      await login(
        email,
        password
      );

      navigate(
        "/dashboard",
        {
          replace: true,
        }
      );

    } catch (error) {

      setError(
        error.response?.data?.message ||
        "Login failed. Please try again."
      );

    } finally {

      setLoading(false);
    }
  }


  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
        background:
          "linear-gradient(135deg, #eef2ff 0%, #f8fafc 45%, #e0e7ff 100%)",
        fontFamily:
          "Inter, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
        boxSizing: "border-box",
      }}
    >

      {/* Main Card */}
      <div
        style={{
          width: "100%",
          maxWidth: "430px",
          background: "#ffffff",
          borderRadius: "20px",
          padding: "40px",
          boxShadow:
            "0 20px 50px rgba(15, 23, 42, 0.12)",
          border:
            "1px solid rgba(226, 232, 240, 0.8)",
          boxSizing: "border-box",
        }}
      >

        {/* Logo / Branding */}
        <div
          style={{
            textAlign: "center",
            marginBottom: "30px",
          }}
        >

          <div
            style={{
              width: "58px",
              height: "58px",
              margin: "0 auto 18px",
              borderRadius: "16px",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              background:
                "linear-gradient(135deg, #4f46e5, #7c3aed)",
              color: "#ffffff",
              fontSize: "27px",
              fontWeight: "800",
              boxShadow:
                "0 10px 25px rgba(79, 70, 229, 0.28)",
            }}
          >
            PM
          </div>


          <h1
            style={{
              margin: "0",
              fontSize: "28px",
              fontWeight: "750",
              color: "#0f172a",
              letterSpacing: "-0.5px",
            }}
          >
            Project Manager
          </h1>


          <p
            style={{
              margin: "9px 0 0",
              fontSize: "14px",
              color: "#64748b",
              lineHeight: "1.6",
            }}
          >
            Sign in to manage your projects
            and tasks.
          </p>

        </div>


        {/* Session Expired Message */}
        {tokenExpired && (
          <div
            style={{
              marginBottom: "20px",
              padding: "12px 14px",
              borderRadius: "10px",
              background: "#fffbeb",
              border: "1px solid #fde68a",
              color: "#92400e",
              fontSize: "13px",
              lineHeight: "1.5",
            }}
          >
            Your session expired.
            Please login again.
          </div>
        )}


        {/* Error Message */}
        {error && (
          <div
            style={{
              marginBottom: "20px",
              padding: "12px 14px",
              borderRadius: "10px",
              background: "#fef2f2",
              border: "1px solid #fecaca",
              color: "#b91c1c",
              fontSize: "13px",
              lineHeight: "1.5",
            }}
          >
            {error}
          </div>
        )}


        {/* Login Form */}
        <form
          onSubmit={handleSubmit}
        >

          {/* Email */}
          <div
            style={{
              marginBottom: "20px",
            }}
          >

            <label
              style={{
                display: "block",
                marginBottom: "8px",
                fontSize: "14px",
                fontWeight: "600",
                color: "#334155",
              }}
            >
              Email
            </label>


            <input
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) =>
                setEmail(e.target.value)
              }
              style={{
                width: "100%",
                height: "48px",
                padding: "0 14px",
                borderRadius: "10px",
                border: "1px solid #cbd5e1",
                outline: "none",
                fontSize: "14px",
                color: "#0f172a",
                background: "#ffffff",
                boxSizing: "border-box",
                transition: "all 0.2s ease",
              }}
              onFocus={(e) => {
                e.target.style.borderColor =
                  "#6366f1";
                e.target.style.boxShadow =
                  "0 0 0 3px rgba(99, 102, 241, 0.12)";
              }}
              onBlur={(e) => {
                e.target.style.borderColor =
                  "#cbd5e1";
                e.target.style.boxShadow =
                  "none";
              }}
            />

          </div>


          {/* Password */}
          <div
            style={{
              marginBottom: "24px",
            }}
          >

            <label
              style={{
                display: "block",
                marginBottom: "8px",
                fontSize: "14px",
                fontWeight: "600",
                color: "#334155",
              }}
            >
              Password
            </label>


            <input
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) =>
                setPassword(e.target.value)
              }
              style={{
                width: "100%",
                height: "48px",
                padding: "0 14px",
                borderRadius: "10px",
                border: "1px solid #cbd5e1",
                outline: "none",
                fontSize: "14px",
                color: "#0f172a",
                background: "#ffffff",
                boxSizing: "border-box",
                transition: "all 0.2s ease",
              }}
              onFocus={(e) => {
                e.target.style.borderColor =
                  "#6366f1";
                e.target.style.boxShadow =
                  "0 0 0 3px rgba(99, 102, 241, 0.12)";
              }}
              onBlur={(e) => {
                e.target.style.borderColor =
                  "#cbd5e1";
                e.target.style.boxShadow =
                  "none";
              }}
            />

          </div>


          {/* Login Button */}
          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              height: "48px",
              border: "none",
              borderRadius: "10px",
              background: loading
                ? "#818cf8"
                : "linear-gradient(135deg, #4f46e5, #7c3aed)",
              color: "#ffffff",
              fontSize: "15px",
              fontWeight: "650",
              cursor: loading
                ? "not-allowed"
                : "pointer",
              boxShadow:
                "0 8px 18px rgba(79, 70, 229, 0.25)",
              transition:
                "transform 0.2s ease, box-shadow 0.2s ease",
            }}
            onMouseEnter={(e) => {
              if (!loading) {
                e.currentTarget.style.transform =
                  "translateY(-1px)";
                e.currentTarget.style.boxShadow =
                  "0 12px 24px rgba(79, 70, 229, 0.32)";
              }
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform =
                "translateY(0)";
              e.currentTarget.style.boxShadow =
                "0 8px 18px rgba(79, 70, 229, 0.25)";
            }}
          >
            {loading
              ? "Signing in..."
              : "Login"}
          </button>

        </form>


        {/* Register Link */}
        <div
          style={{
            marginTop: "26px",
            paddingTop: "22px",
            borderTop: "1px solid #e2e8f0",
            textAlign: "center",
          }}
        >

          <p
            style={{
              margin: "0",
              fontSize: "14px",
              color: "#64748b",
            }}
          >
            Don't have an account?{" "}

            <Link
              to="/register"
              style={{
                color: "#4f46e5",
                fontWeight: "650",
                textDecoration: "none",
              }}
            >
              Create one
            </Link>

          </p>

        </div>

      </div>

    </div>
  );
}