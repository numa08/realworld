import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp(functions.config().firebase);
const firestore = admin.firestore();

interface Tag {
  articleRef: string;
  tag: string;
}

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

export const onArticleTagCreate = functions.firestore
  .document("/users/{userId}/articles/{articleId}/tags/{tag}")
  .onCreate(async (snapshot, context) => {
    await copyToRootWithTagSnapshot(snapshot, context);
  });

export const onArticleTagUpdate = functions.firestore
  .document("/users/{userId}/articles/{articleId}/tags/{tag}")
  .onUpdate(async (snapshot, context) => {
    await copyToRootWithTagSnapshot(snapshot.after, context);
  });

export const onArticleTagdelete = functions.firestore
  .document("/users/{userId}/articles/{articleId}/tags/{tag}")
  .onDelete(async (snapshot, context) => {
    await deleteRootWithTagSnapshot(snapshot, context);
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

async function copyToRootWithTagSnapshot(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  context: functions.EventContext
) {
  const tag = snapshot.data() as Tag;
  const articleSnap = await firestore.doc(tag.articleRef).get();
  const articleId = articleSnap.id;
  const article = articleSnap.data()!;
  await firestore
    .collection("tags")
    .doc(tag.tag)
    .collection("articles")
    .doc(articleId)
    .set(article, { merge: true });
}

async function deleteRootWithTagSnapshot(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  context: functions.EventContext
) {
  const tag = snapshot.data() as Tag;
  const articleSnap = await firestore.doc(tag.articleRef).get();
  const articleId = articleSnap.id;
  await firestore
    .collection("tags")
    .doc(tag.tag)
    .collection("articles")
    .doc(articleId)
    .delete();
}
