import * as admin from 'firebase-admin';

admin.initializeApp();

// Export Admin Modules
export * from './entrypoints/callable/admin/inventario';
export * from './entrypoints/callable/admin/productos';
export * from './entrypoints/callable/admin/config';
