import matplotlib.pyplot as plt
import numpy as np
import itertools

def plot_confusion_matrix(cm, classes,
                          normalize=False,
                          title='Confusion matrix',
                          cmap=plt.cm.Blues):
    """
    This function prints and plots the confusion matrix.
    Normalization can be applied by setting `normalize=True`.
    """
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        print("Normalized confusion matrix")
    else:
        print('Confusion matrix, without normalization')

    print(cm)

    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)

    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
                 horizontalalignment="center",
                 color="white" if cm[i, j] > thresh else "black")

    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.tight_layout()

def remove_stop_words(df,words):
    for word in words:
        word = " " + word + " "
        df.Relato = df.Relato.str.replace(word,' ')
    for ponto in ['.',',','!','?',';',':']:
        df.Relato = df.Relato.str.replace(ponto,'')
        
    return df

def convert_to_one_hot(Y):
    nclasses = len(Y.value_counts())
    klass_to_idx = {klass: idx for idx, klass in enumerate(Y.value_counts().index)}
    idx_to_klass = {idx: klass for idx, klass in enumerate(Y.value_counts().index)}
    Y_idx = Y.apply(lambda w: klass_to_idx[w])
    Y_ohe = np.eye(nclasses)[Y_idx]
    return Y_ohe, Y_idx, klass_to_idx, idx_to_klass