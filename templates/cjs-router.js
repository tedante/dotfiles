const router = require("express").Router()

router.get("/", (req, res) => {
  res.send("nicee")
})

module.exports = router
