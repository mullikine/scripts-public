print(np.array([5,3]))


#def plot_stuff(inputs, outputs, losses, net_func, n_hidden):
#    fig,axes = plt.subplots(1,2,figsize=(12,6))
#
#    axes[0].plot(np.arange(losses.shape[0])+1, losses)
#    axes[0].set_xlabel('iteration')
#    axes[0].set_ylabel('loss')
#    axes[0].set_xscale('log')
#    axes[0].set_yscale('log')
#
#    x,y = np.mgrid[inputs[:,0].min():inputs[:,0].max():51j, inputs[:,1].min():inputs[:,1].max():51j]
#    z = net_func( np.c_[x.flatten(), y.flatten()] ).reshape(x.shape)
#
#    axes[1].contourf(x,y,z, cmap=plt.cm.RdBu, alpha=0.6)
#    axes[1].plot(inputs[outputs==0,0], inputs[outputs==0,1], 'or') 
#    axes[1].plot(inputs[outputs==1,0], inputs[outputs==1,1], 'sb') 
#    axes[1].set_title('Percent missclassified: %0.2f%%' % (((net_func(inputs)>0.5) != outputs.astype(np.bool)).mean()*100))
#
#    fig.suptitle('Shallow net with %d hidden units'%n_hidden)
#    plt.show()

#if __name__=='__main__':
#    n_hidden = 40
#    inputs, outputs = gen_data(n_samples_per_class=100)
#    losses, net_func = train_neural_network(inputs=inputs, outputs=outputs, n_hidden=n_hidden, n_iters=int(2000), learning_rate=0.1)
#    plot_stuff(inputs, outputs, losses, net_func, n_hidden)
