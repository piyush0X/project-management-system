# Testing Instructions

## API

Use VS Code REST Client to test registration, login, current user, project CRUD, task CRUD and dashboard.

## Cross-platform

Use the same account on web and Android.

1. Create a project on web → verify Android.
2. Create a task on web → verify Android.
3. Create/edit a project on Android → verify web.
4. Create/edit/delete a task on Android → verify web.
5. Test project search/status filter.
6. Test task search/status/priority filters.
7. Test logout and invalid/expired JWT.
8. Test network failure handling.
9. Verify dashboard statistics after creating/completing records.

Final architecture:

```text
Same account
     ↓
Shared PostgreSQL database
     ↓
Shared Express API
   ↙         ↘
React Web   Flutter Android
```
