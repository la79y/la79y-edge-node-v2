const { query } = require("./dbClient");

const fetchConfigByKey = async (key) => {
  try {
    const res = await query(
      `select * from la79y.public."GlobalConfigs" where key='${key}'`,
      []
    );
    console.log(res.rows);
    return res.rows;
  } catch (err) {
    console.error("Error executing query", err.stack);
    throw err;
  }
};
const updateSessionToUsed = async (sessionId, username, resource) => {
  try {
    const res = await query(
      `
            update  "Sessions"
            set used = true
            where id = '${sessionId}'
              and username = '${username}'
              and resource = '${resource}'
              and is_streamer = false
              and used = false;`,
      []
    );
    console.log(res.rows);
    return res.rows;
  } catch (err) {
    console.error("Error executing query", err.stack);
    throw err;
  }
};
const fetchSessionIdByResourceAndUser = async (
  sessionId,
  username,
  resource,
  used
) => {
  try {
    const res = await query(
      `
            select * from "Sessions"
            where id = '${sessionId}'
              and username = '${username}'
              and resource = '${resource}'
              and is_streamer = false
              and used = ${used}`,
      []
    );
    console.log(res.rows);
    return res.rows;
  } catch (err) {
    console.error("Error executing query", err.stack);
    throw err;
  }
};

module.exports = {
  fetchConfigByKey,
  fetchSessionIdByResourceAndUser,
  updateSessionToUsed,
}; // Export the function for use in other files
