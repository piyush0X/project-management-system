import {
  useState,
} from "react";

import {
  Link,
  useNavigate,
} from "react-router-dom";

import { useAuth } from "../context/AuthContext";


export default function Register() {

  const {
    register,
  } = useAuth();

  const navigate =
    useNavigate();


  const [
    fullName,
    setFullName,
  ] = useState("");


  const [
    email,
    setEmail,
  ] = useState("");


  const [
    password,
    setPassword,
  ] = useState("");


  const [
    confirmPassword,
    setConfirmPassword,
  ] = useState("");


  const [
    error,
    setError,
  ] = useState("");


  const [
    loading,
    setLoading,
  ] = useState(false);


  async function handleSubmit(event) {

    event.preventDefault();

    setError("");


    if (
      !fullName.trim() ||
      !email.trim() ||
      !password
    ) {

      setError(
        "Please fill in all required fields."
      );

      return;
    }


    if (password.length < 6) {

      setError(
        "Password must be at least 6 characters."
      );

      return;
    }


    if (
      password !== confirmPassword
    ) {

      setError(
        "Passwords do not match."
      );

      return;
    }


    try {

      setLoading(true);

      await register(
        fullName,
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
        "Registration failed."
      );

    } finally {

      setLoading(false);
    }
  }


  return (
    <div className="auth-page">

      <div className="auth-card">

        <h1>
          Create Account
        </h1>

        <p className="auth-subtitle">
          Start managing your projects.
        </p>


        {error && (
          <div className="alert error">
            {error}
          </div>
        )}


        <form
          onSubmit={handleSubmit}
        >

          <label>
            Full Name
          </label>

          <input
            type="text"
            placeholder="Your full name"
            value={fullName}
            onChange={(e) =>
              setFullName(e.target.value)
            }
          />


          <label>
            Email
          </label>

          <input
            type="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) =>
              setEmail(e.target.value)
            }
          />


          <label>
            Password
          </label>

          <input
            type="password"
            placeholder="At least 6 characters"
            value={password}
            onChange={(e) =>
              setPassword(e.target.value)
            }
          />


          <label>
            Confirm Password
          </label>

          <input
            type="password"
            placeholder="Repeat password"
            value={confirmPassword}
            onChange={(e) =>
              setConfirmPassword(e.target.value)
            }
          />


          <button
            type="submit"
            disabled={loading}
          >
            {loading
              ? "Creating account..."
              : "Register"}
          </button>

        </form>


        <p className="auth-footer">
          Already have an account?{" "}
          <Link to="/login">
            Login
          </Link>
        </p>

      </div>

    </div>
  );
}