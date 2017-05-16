/****************************************************************************
** Meta object code from reading C++ file 'graphic_scene.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/graphic_scene.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'graphic_scene.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_OpenGLScene[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      17,   16,   16,   16, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QRL_OpenGLScene[] = {
    "QRL_OpenGLScene\0\0setBackgroundColor()\0"
};

void QRL_OpenGLScene::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_OpenGLScene *_t = static_cast<QRL_OpenGLScene *>(_o);
        switch (_id) {
        case 0: _t->setBackgroundColor(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObjectExtraData QRL_OpenGLScene::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_OpenGLScene::staticMetaObject = {
    { &QGraphicsScene::staticMetaObject, qt_meta_stringdata_QRL_OpenGLScene,
      qt_meta_data_QRL_OpenGLScene, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_OpenGLScene::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_OpenGLScene::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_OpenGLScene::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_OpenGLScene))
        return static_cast<void*>(const_cast< QRL_OpenGLScene*>(this));
    return QGraphicsScene::qt_metacast(_clname);
}

int QRL_OpenGLScene::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QGraphicsScene::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
