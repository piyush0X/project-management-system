import {
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";

import api from "../services/api";

const AuthContext = createContext(null);


export function AuthProvider({ children }) {

  const [user, setUser] = useState(() => {

    const savedUser =
      localStorage.getItem("user");

    return savedUser
      ? JSON.parse(savedUser)
      : null;
  });


  const [loading, setLoading] =
    useState(true);


  // ==========================================
  // CHECK AUTHENTICATION
  // ==========================================

  useEffect(() => {

    const token =
      localStorage.getItem("token");

    if (!token) {
      setLoading(false);
      return;
    }


    api.get("/auth/me")
      .then((response) => {

        const currentUser =
          response.data.data.user;

        setUser(currentUser);

        localStorage.setItem(
          "user",
          JSON.stringify(currentUser)
        );
      })
      .catch(() => {

        localStorage.removeItem("token");
        localStorage.removeItem("user");

        setUser(null);
      })
      .finally(() => {

        setLoading(false);
      });

  }, []);


  // ==========================================
  // LOGIN
  // ==========================================

  async function login(email, password) {

    const response =
      await api.post(
        "/auth/login",
        {
          email,
          password,
        }
      );


    const {
      token,
      user: loggedInUser,
    } = response.data.data;


    localStorage.setItem(
      "token",
      token
    );

    localStorage.setItem(
      "user",
      JSON.stringify(loggedInUser)
    );


    setUser(loggedInUser);

    return response.data;
  }


  // ==========================================
  // REGISTER
  // ==========================================

  async function register(
    full_name,
    email,
    password
  ) {

    const response =
      await api.post(
        "/auth/register",
        {
          full_name,
          email,
          password,
        }
      );


    const {
      token,
      user: registeredUser,
    } = response.data.data;


    localStorage.setItem(
      "token",
      token
    );

    localStorage.setItem(
      "user",
      JSON.stringify(registeredUser)
    );


    setUser(registeredUser);

    return response.data;
  }


  // ==========================================
  // LOGOUT
  // ==========================================

  async function logout() {

    try {

      if (localStorage.getItem("token")) {
        await api.post("/auth/logout");
      }

    } catch (error) {

      console.error(
        "Logout error:",
        error
      );

    } finally {

      localStorage.removeItem("token");
      localStorage.removeItem("user");

      setUser(null);
    }
  }


  const value = {
    user,
    loading,
    login,
    register,
    logout,
  };


  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}


export function useAuth() {
  return useContext(AuthContext);
}