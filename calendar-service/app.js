import express from "express";

const app = express();
const port = process.env.PORT || 8000;

function someDaysAgo(days) {
  const currentDate = new Date();
  currentDate.setDate(currentDate.getDate() - days);
  return currentDate;
}

function someDaysBeyond(days) {
  const currentDate = new Date();
  currentDate.setDate(currentDate.getDate() + days);
  return currentDate;
}

app.use(express.json());

app.get("/events", (req, res) => {
  let user_id = req.query.user_id
  if (!user_id) {
    res.send("User Does Not Exist", 404)
    return
  }

  res.json({
    events: [
      {
        id: 1,
        name: "Hangout",
        duration: 30,
        date: someDaysAgo(3).toLocaleDateString('en-US'),
        attendees: 2
      },
      {
        id: 2,
        name: "Pre-Screen",
        duration: 60,
        date: someDaysAgo(5).toLocaleDateString('en-US'),
        attendees: 3
      },
      {
        id: 3,
        name: "Group Interview",
        duration: 120,
        date: someDaysAgo(4).toLocaleDateString('en-US'),
        attendees: 3
      },
      {
        id: 4,
        name: "1on1",
        duration: 60,
        date: someDaysBeyond(4).toLocaleDateString('en-US'),
        attendees: 2
      }
    ]
  })
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
