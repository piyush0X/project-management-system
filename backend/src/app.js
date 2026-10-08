const express = require("express");
const cors = require("cors");
require("dotenv").config();

const dashboardRoutes = require("./routes/dashboardRoutes");

const authRoutes = require("./routes/authRoutes");
const projectRoutes = require("./routes/projectRoutes");
const taskRoutes = require("./routes/taskRoutes");



const app = express();

app.use(
  cors({
    origin: process.env.CLIENT_URL,
    credentials: true,
  })
);

app.use(express.json());


// Health
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "Project Management API is running",
  });
});


// Authentication
app.use("/api/auth", authRoutes);

app.use("/api", taskRoutes);


// Projects + project tasks
app.use("/api/projects", projectRoutes);


// Individual tasks


app.use("/api/dashboard", dashboardRoutes);


module.exports = app;