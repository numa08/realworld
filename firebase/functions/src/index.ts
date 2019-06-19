import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp(functions.config().firebase);
const firestore = admin.firestore();

export const onUserArticleCreate = functions.firestore
  .document("/users/{userId}/articles/{articleId}")
  .onCreate(async (snapshot, context) => {
    await copyToRootWithUserArticleSnapshot(snapshot, context);
  });

export const onUserArticleUpdate = functions.firestore
  .document("/users/{userId}/articles/{articleId}")
  .onUpdate(async (snapshot, context) => {
    await copyToRootWithUserArticleSnapshot(snapshot.after, context);
  });

export const onUserAritlceDelete = functions.firestore
  .document("/users/{userId}/articles/{articleId}")
  .onDelete(async (snapshot, context) => {
    await deleteRootWithUserAritcleSnapshot(snapshot, context);
  });

async function copyToRootWithUserArticleSnapshot(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  context: functions.EventContext
) {
  const id = snapshot.id;
  const data = snapshot.data()!;
  await firestore
    .collection("articles")
    .doc(id)
    .set(data, { merge: true });
}

async function deleteRootWithUserAritcleSnapshot(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  context: functions.EventContext
) {
  const id = snapshot.id;
  await firestore
    .collection("articles")
    .doc(id)
    .delete();
}
