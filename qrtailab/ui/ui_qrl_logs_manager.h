/********************************************************************************
** Form generated from reading UI file 'qrl_logs_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_LOGS_MANAGER_H
#define UI_QRL_LOGS_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QListWidget>
#include <QtGui/QProgressBar>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QSpinBox>
#include <QtGui/QTabWidget>
#include <QtGui/QTableView>
#include <QtGui/QToolBox>
#include <QtGui/QWidget>
#include "qwt_counter.h"

QT_BEGIN_NAMESPACE

class Ui_QRL_LogsManager
{
public:
    QGridLayout *gridLayout_2;
    QHBoxLayout *hboxLayout;
    QSpacerItem *spacerItem;
    QPushButton *helpButton;
    QSpacerItem *spacerItem1;
    QPushButton *closeButton;
    QSpacerItem *spacerItem2;
    QListWidget *logListWidget;
    QTabWidget *tabWidget;
    QWidget *Log;
    QGridLayout *gridLayout;
    QCheckBox *showCheckBox;
    QCheckBox *holdCheckBox;
    QToolBox *toolBox;
    QWidget *page_2;
    QGridLayout *gridLayout_3;
    QLabel *label_3;
    QPushButton *dirPushButton;
    QLineEdit *dirLineEdit;
    QLabel *label_2;
    QLineEdit *fileLineEdit;
    QLabel *label;
    QwtCounter *timeCounter;
    QProgressBar *saveProgressBar;
    QPushButton *savePushButton;
    QPushButton *stopPushButton;
    QComboBox *viewComboBox;
    QwtCounter *rrCounter;
    QLabel *label_15;
    QWidget *matrixView;
    QGridLayout *gridLayout_4;
    QLineEdit *rowDimLineEdit;
    QLineEdit *colDimLineEdit;
    QComboBox *delegateComboBox;
    QLabel *label_5;
    QTableView *legendTableView;
    QSpinBox *pixelSizeSpinBox;
    QLabel *label_6;
    QSpacerItem *horizontalSpacer;
    QLabel *label_4;
    QwtCounter *minScaleCounter;
    QLabel *label_7;
    QwtCounter *maxScaleCounter;
    QCheckBox *viewNumberCheckBox;
    QWidget *xyPlot;
    QGridLayout *gridLayout_5;
    QHBoxLayout *horizontalLayout;
    QLabel *label_9;
    QwtCounter *histLengthDistCounter;
    QHBoxLayout *horizontalLayout_2;
    QLabel *label_10;
    QwtCounter *pointDistCounter;
    QHBoxLayout *horizontalLayout_3;
    QLabel *label_11;
    QComboBox *dxComboBox;
    QHBoxLayout *horizontalLayout_4;
    QLabel *label_12;
    QwtCounter *xOffsetCounter;
    QHBoxLayout *horizontalLayout_5;
    QLabel *label_13;
    QComboBox *dyComboBox;
    QHBoxLayout *horizontalLayout_6;
    QLabel *label_14;
    QwtCounter *yOffsetCounter;

    void setupUi(QDialog *QRL_LogsManager)
    {
        if (QRL_LogsManager->objectName().isEmpty())
            QRL_LogsManager->setObjectName(QString::fromUtf8("QRL_LogsManager"));
        QRL_LogsManager->resize(450, 380);
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(QRL_LogsManager->sizePolicy().hasHeightForWidth());
        QRL_LogsManager->setSizePolicy(sizePolicy);
        QRL_LogsManager->setMinimumSize(QSize(450, 380));
        QRL_LogsManager->setMaximumSize(QSize(450, 380));
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/log_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        QRL_LogsManager->setWindowIcon(icon);
        gridLayout_2 = new QGridLayout(QRL_LogsManager);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        hboxLayout = new QHBoxLayout();
        hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
        spacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem);

        helpButton = new QPushButton(QRL_LogsManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));

        hboxLayout->addWidget(helpButton);

        spacerItem1 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem1);

        closeButton = new QPushButton(QRL_LogsManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));

        hboxLayout->addWidget(closeButton);

        spacerItem2 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem2);


        gridLayout_2->addLayout(hboxLayout, 1, 0, 1, 3);

        logListWidget = new QListWidget(QRL_LogsManager);
        logListWidget->setObjectName(QString::fromUtf8("logListWidget"));
        sizePolicy.setHeightForWidth(logListWidget->sizePolicy().hasHeightForWidth());
        logListWidget->setSizePolicy(sizePolicy);
        logListWidget->setMaximumSize(QSize(16777215, 16777215));
        logListWidget->setBaseSize(QSize(100, 0));

        gridLayout_2->addWidget(logListWidget, 0, 0, 1, 1);

        tabWidget = new QTabWidget(QRL_LogsManager);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        Log = new QWidget();
        Log->setObjectName(QString::fromUtf8("Log"));
        gridLayout = new QGridLayout(Log);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        showCheckBox = new QCheckBox(Log);
        showCheckBox->setObjectName(QString::fromUtf8("showCheckBox"));

        gridLayout->addWidget(showCheckBox, 0, 0, 1, 1);

        holdCheckBox = new QCheckBox(Log);
        holdCheckBox->setObjectName(QString::fromUtf8("holdCheckBox"));

        gridLayout->addWidget(holdCheckBox, 0, 2, 1, 1);

        toolBox = new QToolBox(Log);
        toolBox->setObjectName(QString::fromUtf8("toolBox"));
        page_2 = new QWidget();
        page_2->setObjectName(QString::fromUtf8("page_2"));
        page_2->setGeometry(QRect(0, 0, 288, 208));
        gridLayout_3 = new QGridLayout(page_2);
        gridLayout_3->setObjectName(QString::fromUtf8("gridLayout_3"));
        label_3 = new QLabel(page_2);
        label_3->setObjectName(QString::fromUtf8("label_3"));

        gridLayout_3->addWidget(label_3, 1, 0, 1, 1);

        dirPushButton = new QPushButton(page_2);
        dirPushButton->setObjectName(QString::fromUtf8("dirPushButton"));

        gridLayout_3->addWidget(dirPushButton, 1, 1, 1, 1);

        dirLineEdit = new QLineEdit(page_2);
        dirLineEdit->setObjectName(QString::fromUtf8("dirLineEdit"));

        gridLayout_3->addWidget(dirLineEdit, 2, 0, 1, 2);

        label_2 = new QLabel(page_2);
        label_2->setObjectName(QString::fromUtf8("label_2"));

        gridLayout_3->addWidget(label_2, 3, 0, 1, 1);

        fileLineEdit = new QLineEdit(page_2);
        fileLineEdit->setObjectName(QString::fromUtf8("fileLineEdit"));

        gridLayout_3->addWidget(fileLineEdit, 3, 1, 1, 1);

        label = new QLabel(page_2);
        label->setObjectName(QString::fromUtf8("label"));

        gridLayout_3->addWidget(label, 4, 0, 1, 1);

        timeCounter = new QwtCounter(page_2);
        timeCounter->setObjectName(QString::fromUtf8("timeCounter"));
        timeCounter->setNumButtons(0);
        timeCounter->setMinValue(0);
        timeCounter->setMaxValue(1e+06);
        timeCounter->setValue(1);

        gridLayout_3->addWidget(timeCounter, 4, 1, 1, 1);

        saveProgressBar = new QProgressBar(page_2);
        saveProgressBar->setObjectName(QString::fromUtf8("saveProgressBar"));
        saveProgressBar->setEnabled(false);
        saveProgressBar->setValue(0);
        saveProgressBar->setTextVisible(true);

        gridLayout_3->addWidget(saveProgressBar, 5, 0, 1, 2);

        savePushButton = new QPushButton(page_2);
        savePushButton->setObjectName(QString::fromUtf8("savePushButton"));
        savePushButton->setCheckable(true);
        savePushButton->setAutoDefault(false);

        gridLayout_3->addWidget(savePushButton, 6, 0, 1, 1);

        stopPushButton = new QPushButton(page_2);
        stopPushButton->setObjectName(QString::fromUtf8("stopPushButton"));
        stopPushButton->setEnabled(false);

        gridLayout_3->addWidget(stopPushButton, 6, 1, 1, 1);

        toolBox->addItem(page_2, QString::fromUtf8("Saving"));

        gridLayout->addWidget(toolBox, 5, 0, 1, 3);

        viewComboBox = new QComboBox(Log);
        viewComboBox->setObjectName(QString::fromUtf8("viewComboBox"));

        gridLayout->addWidget(viewComboBox, 3, 0, 1, 1);

        rrCounter = new QwtCounter(Log);
        rrCounter->setObjectName(QString::fromUtf8("rrCounter"));
        rrCounter->setNumButtons(1);
        rrCounter->setProperty("basicstep", QVariant(0.1));
        rrCounter->setMaxValue(1e+07);
        rrCounter->setValue(10);

        gridLayout->addWidget(rrCounter, 3, 2, 1, 1);

        label_15 = new QLabel(Log);
        label_15->setObjectName(QString::fromUtf8("label_15"));

        gridLayout->addWidget(label_15, 3, 1, 1, 1);

        tabWidget->addTab(Log, QString());
        matrixView = new QWidget();
        matrixView->setObjectName(QString::fromUtf8("matrixView"));
        gridLayout_4 = new QGridLayout(matrixView);
        gridLayout_4->setObjectName(QString::fromUtf8("gridLayout_4"));
        rowDimLineEdit = new QLineEdit(matrixView);
        rowDimLineEdit->setObjectName(QString::fromUtf8("rowDimLineEdit"));
        rowDimLineEdit->setReadOnly(true);

        gridLayout_4->addWidget(rowDimLineEdit, 1, 0, 1, 1);

        colDimLineEdit = new QLineEdit(matrixView);
        colDimLineEdit->setObjectName(QString::fromUtf8("colDimLineEdit"));
        colDimLineEdit->setAutoFillBackground(false);
        colDimLineEdit->setReadOnly(true);

        gridLayout_4->addWidget(colDimLineEdit, 1, 2, 1, 1);

        delegateComboBox = new QComboBox(matrixView);
        delegateComboBox->setObjectName(QString::fromUtf8("delegateComboBox"));

        gridLayout_4->addWidget(delegateComboBox, 1, 3, 1, 1);

        label_5 = new QLabel(matrixView);
        label_5->setObjectName(QString::fromUtf8("label_5"));

        gridLayout_4->addWidget(label_5, 2, 3, 1, 1);

        legendTableView = new QTableView(matrixView);
        legendTableView->setObjectName(QString::fromUtf8("legendTableView"));

        gridLayout_4->addWidget(legendTableView, 2, 0, 6, 3);

        pixelSizeSpinBox = new QSpinBox(matrixView);
        pixelSizeSpinBox->setObjectName(QString::fromUtf8("pixelSizeSpinBox"));
        pixelSizeSpinBox->setMaximum(500);
        pixelSizeSpinBox->setValue(24);

        gridLayout_4->addWidget(pixelSizeSpinBox, 7, 3, 1, 1);

        label_6 = new QLabel(matrixView);
        label_6->setObjectName(QString::fromUtf8("label_6"));

        gridLayout_4->addWidget(label_6, 6, 3, 1, 1);

        horizontalSpacer = new QSpacerItem(21, 25, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout_4->addItem(horizontalSpacer, 1, 1, 1, 1);

        label_4 = new QLabel(matrixView);
        label_4->setObjectName(QString::fromUtf8("label_4"));

        gridLayout_4->addWidget(label_4, 0, 0, 1, 3);

        minScaleCounter = new QwtCounter(matrixView);
        minScaleCounter->setObjectName(QString::fromUtf8("minScaleCounter"));
        minScaleCounter->setNumButtons(0);
        minScaleCounter->setProperty("basicstep", QVariant(1));
        minScaleCounter->setMinValue(-1e+07);
        minScaleCounter->setMaxValue(1e+07);

        gridLayout_4->addWidget(minScaleCounter, 3, 3, 1, 1);

        label_7 = new QLabel(matrixView);
        label_7->setObjectName(QString::fromUtf8("label_7"));

        gridLayout_4->addWidget(label_7, 4, 3, 1, 1);

        maxScaleCounter = new QwtCounter(matrixView);
        maxScaleCounter->setObjectName(QString::fromUtf8("maxScaleCounter"));
        maxScaleCounter->setNumButtons(0);
        maxScaleCounter->setProperty("basicstep", QVariant(1));
        maxScaleCounter->setMinValue(-1e+07);
        maxScaleCounter->setMaxValue(1e+07);
        maxScaleCounter->setValue(1);

        gridLayout_4->addWidget(maxScaleCounter, 5, 3, 1, 1);

        viewNumberCheckBox = new QCheckBox(matrixView);
        viewNumberCheckBox->setObjectName(QString::fromUtf8("viewNumberCheckBox"));
        QFont font;
        font.setPointSize(9);
        viewNumberCheckBox->setFont(font);

        gridLayout_4->addWidget(viewNumberCheckBox, 0, 3, 1, 1);

        tabWidget->addTab(matrixView, QString());
        xyPlot = new QWidget();
        xyPlot->setObjectName(QString::fromUtf8("xyPlot"));
        gridLayout_5 = new QGridLayout(xyPlot);
        gridLayout_5->setObjectName(QString::fromUtf8("gridLayout_5"));
        horizontalLayout = new QHBoxLayout();
        horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
        label_9 = new QLabel(xyPlot);
        label_9->setObjectName(QString::fromUtf8("label_9"));

        horizontalLayout->addWidget(label_9);

        histLengthDistCounter = new QwtCounter(xyPlot);
        histLengthDistCounter->setObjectName(QString::fromUtf8("histLengthDistCounter"));
        histLengthDistCounter->setNumButtons(0);
        histLengthDistCounter->setProperty("basicstep", QVariant(1));
        histLengthDistCounter->setMaxValue(1e+09);
        histLengthDistCounter->setValue(100);

        horizontalLayout->addWidget(histLengthDistCounter);


        gridLayout_5->addLayout(horizontalLayout, 0, 0, 1, 2);

        horizontalLayout_2 = new QHBoxLayout();
        horizontalLayout_2->setObjectName(QString::fromUtf8("horizontalLayout_2"));
        label_10 = new QLabel(xyPlot);
        label_10->setObjectName(QString::fromUtf8("label_10"));

        horizontalLayout_2->addWidget(label_10);

        pointDistCounter = new QwtCounter(xyPlot);
        pointDistCounter->setObjectName(QString::fromUtf8("pointDistCounter"));
        pointDistCounter->setNumButtons(0);
        pointDistCounter->setProperty("basicstep", QVariant(1));
        pointDistCounter->setMaxValue(1e+09);
        pointDistCounter->setValue(100);

        horizontalLayout_2->addWidget(pointDistCounter);


        gridLayout_5->addLayout(horizontalLayout_2, 1, 0, 1, 2);

        horizontalLayout_3 = new QHBoxLayout();
        horizontalLayout_3->setObjectName(QString::fromUtf8("horizontalLayout_3"));
        label_11 = new QLabel(xyPlot);
        label_11->setObjectName(QString::fromUtf8("label_11"));

        horizontalLayout_3->addWidget(label_11);

        dxComboBox = new QComboBox(xyPlot);
        dxComboBox->setObjectName(QString::fromUtf8("dxComboBox"));
        dxComboBox->setEditable(true);

        horizontalLayout_3->addWidget(dxComboBox);


        gridLayout_5->addLayout(horizontalLayout_3, 2, 0, 1, 1);

        horizontalLayout_4 = new QHBoxLayout();
        horizontalLayout_4->setObjectName(QString::fromUtf8("horizontalLayout_4"));
        label_12 = new QLabel(xyPlot);
        label_12->setObjectName(QString::fromUtf8("label_12"));

        horizontalLayout_4->addWidget(label_12);

        xOffsetCounter = new QwtCounter(xyPlot);
        xOffsetCounter->setObjectName(QString::fromUtf8("xOffsetCounter"));
        xOffsetCounter->setNumButtons(0);
        xOffsetCounter->setMinValue(-1e+08);
        xOffsetCounter->setMaxValue(1e+08);

        horizontalLayout_4->addWidget(xOffsetCounter);


        gridLayout_5->addLayout(horizontalLayout_4, 2, 1, 1, 1);

        horizontalLayout_5 = new QHBoxLayout();
        horizontalLayout_5->setObjectName(QString::fromUtf8("horizontalLayout_5"));
        label_13 = new QLabel(xyPlot);
        label_13->setObjectName(QString::fromUtf8("label_13"));

        horizontalLayout_5->addWidget(label_13);

        dyComboBox = new QComboBox(xyPlot);
        dyComboBox->setObjectName(QString::fromUtf8("dyComboBox"));
        dyComboBox->setEditable(true);

        horizontalLayout_5->addWidget(dyComboBox);


        gridLayout_5->addLayout(horizontalLayout_5, 3, 0, 1, 1);

        horizontalLayout_6 = new QHBoxLayout();
        horizontalLayout_6->setObjectName(QString::fromUtf8("horizontalLayout_6"));
        label_14 = new QLabel(xyPlot);
        label_14->setObjectName(QString::fromUtf8("label_14"));

        horizontalLayout_6->addWidget(label_14);

        yOffsetCounter = new QwtCounter(xyPlot);
        yOffsetCounter->setObjectName(QString::fromUtf8("yOffsetCounter"));
        yOffsetCounter->setNumButtons(0);
        yOffsetCounter->setMinValue(-1e+08);
        yOffsetCounter->setMaxValue(1e+08);

        horizontalLayout_6->addWidget(yOffsetCounter);


        gridLayout_5->addLayout(horizontalLayout_6, 3, 1, 1, 1);

        tabWidget->addTab(xyPlot, QString());

        gridLayout_2->addWidget(tabWidget, 0, 2, 1, 1);


        retranslateUi(QRL_LogsManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_LogsManager, SLOT(hide()));

        tabWidget->setCurrentIndex(0);
        toolBox->setCurrentIndex(0);
        dxComboBox->setCurrentIndex(6);
        dyComboBox->setCurrentIndex(6);


        QMetaObject::connectSlotsByName(QRL_LogsManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_LogsManager)
    {
        QRL_LogsManager->setWindowTitle(QApplication::translate("QRL_LogsManager", "Logs Manager", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_LogsManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_LogsManager", "Close Manager", 0, QApplication::UnicodeUTF8));
        showCheckBox->setText(QApplication::translate("QRL_LogsManager", "Show/Hide", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        holdCheckBox->setToolTip(QApplication::translate("QRL_LogsManager", "stop plotting will reduce cpu load. Saving is still possible!", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        holdCheckBox->setText(QApplication::translate("QRL_LogsManager", "hold Plot", 0, QApplication::UnicodeUTF8));
        label_3->setText(QApplication::translate("QRL_LogsManager", "Directory", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        dirPushButton->setToolTip(QApplication::translate("QRL_LogsManager", "set directory for saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        dirPushButton->setText(QApplication::translate("QRL_LogsManager", "Set Dir", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        dirLineEdit->setToolTip(QApplication::translate("QRL_LogsManager", "Directory in which the file will be saved", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        dirLineEdit->setText(QApplication::translate("QRL_LogsManager", "./", 0, QApplication::UnicodeUTF8));
        label_2->setText(QApplication::translate("QRL_LogsManager", "Filename", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        fileLineEdit->setToolTip(QApplication::translate("QRL_LogsManager", "Filename", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        label->setText(QApplication::translate("QRL_LogsManager", "Time [s]:", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        timeCounter->setToolTip(QApplication::translate("QRL_LogsManager", "Time duration of the next saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        saveProgressBar->setFormat(QApplication::translate("QRL_LogsManager", "%p%", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        savePushButton->setToolTip(QApplication::translate("QRL_LogsManager", "start saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        savePushButton->setText(QApplication::translate("QRL_LogsManager", "Save", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        stopPushButton->setToolTip(QApplication::translate("QRL_LogsManager", "stop saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        stopPushButton->setText(QApplication::translate("QRL_LogsManager", "stop", 0, QApplication::UnicodeUTF8));
        toolBox->setItemText(toolBox->indexOf(page_2), QApplication::translate("QRL_LogsManager", "Saving", 0, QApplication::UnicodeUTF8));
        viewComboBox->clear();
        viewComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_LogsManager", "Matrix view", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "x-y plot", 0, QApplication::UnicodeUTF8)
        );
        label_15->setText(QApplication::translate("QRL_LogsManager", "FPS:", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(Log), QApplication::translate("QRL_LogsManager", "Log", 0, QApplication::UnicodeUTF8));
        delegateComboBox->clear();
        delegateComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_LogsManager", "Colorbar", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "Black/White", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "Pixel", 0, QApplication::UnicodeUTF8)
        );
        label_5->setText(QApplication::translate("QRL_LogsManager", "Fullscale from:", 0, QApplication::UnicodeUTF8));
        label_6->setText(QApplication::translate("QRL_LogsManager", "Cell size (px):", 0, QApplication::UnicodeUTF8));
        label_4->setText(QApplication::translate("QRL_LogsManager", "Matrix Dim (row x col):", 0, QApplication::UnicodeUTF8));
        label_7->setText(QApplication::translate("QRL_LogsManager", "to", 0, QApplication::UnicodeUTF8));
        viewNumberCheckBox->setText(QApplication::translate("QRL_LogsManager", "View Cell Number", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(matrixView), QApplication::translate("QRL_LogsManager", "Matrix View Options", 0, QApplication::UnicodeUTF8));
        label_9->setText(QApplication::translate("QRL_LogsManager", "Hist length", 0, QApplication::UnicodeUTF8));
        label_10->setText(QApplication::translate("QRL_LogsManager", "Point distance", 0, QApplication::UnicodeUTF8));
        label_11->setText(QApplication::translate("QRL_LogsManager", "dx", 0, QApplication::UnicodeUTF8));
        dxComboBox->clear();
        dxComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_LogsManager", "0.005", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.01", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.05", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "2", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "10", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "50", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "100", 0, QApplication::UnicodeUTF8)
        );
        label_12->setText(QApplication::translate("QRL_LogsManager", "offset x", 0, QApplication::UnicodeUTF8));
        label_13->setText(QApplication::translate("QRL_LogsManager", "dy", 0, QApplication::UnicodeUTF8));
        dyComboBox->clear();
        dyComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_LogsManager", "0.005", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.01", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.05", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "0.5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "2", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "10", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "50", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LogsManager", "100", 0, QApplication::UnicodeUTF8)
        );
        label_14->setText(QApplication::translate("QRL_LogsManager", "offset y", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(xyPlot), QApplication::translate("QRL_LogsManager", "X-Y Plot Options", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_LogsManager: public Ui_QRL_LogsManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_LOGS_MANAGER_H
