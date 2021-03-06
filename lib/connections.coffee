UserStatus.on "sessionLogin", (userId, sessionId, ipAddr) ->


UserStatus.on "sessionLogout", (userId, sessionId, ipAddr) ->
  # TODO record disconnection

Meteor.methods
  "inactive": (data) ->
    # TODO implement tracking inactivity
    # We don't trust client timestamps, but only as identifier and use difference
    console.log data.start, data.time

TurkServer.handleConnection = (doc) ->
  # Make sure any previous assignments are recorded as returned
  Assignments.update {
    hitId: doc.hitId
    assignmentId: doc.assignmentId
    workerId: {$not: doc.workerId}
  }, {
    $set:
      status: "RETURNED"
  }, { multi: true }

  # Track this worker as assigned
  Assignments.upsert {
    hitId: doc.hitId
    assignmentId: doc.assignmentId
    workerId: doc.workerId
  }, {
    $set:
      status: "ASSIGNED"
    # Shouldn't have a problem here as we reject multiple connections on login
      ipAddr: UserSessions.findOne(userId: doc.userId).ipAddr
  }

  # TODO Does the worker need to take quiz/tutorial?

  # Is worker in part of an active group (experiment)?
  if Grouping.findOne(userId: doc.userId)
    # TODO record reconnection
    return

  # None of the above, throw them into the assignment mechanism
  if Batches.findOne(active: true).lobby
    TurkServer.addToLobby(userId)
  else
    TurkServer.assignUser(userId)

TurkServer.assignUser = (userId) ->



