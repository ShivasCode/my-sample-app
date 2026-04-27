//
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello from Harbor → ArgoCD → EKS! V2");
});

app.listen(3000, () => console.log("Fix Server running on 3000"));
